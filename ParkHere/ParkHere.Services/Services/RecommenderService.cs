using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using Microsoft.Extensions.DependencyInjection;
using ParkHere.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ParkHere.Services.Services
{
    public class RecommenderService
    {
        private static MLContext _mlContext = new MLContext();
        private static object _mlLock = new object();
        private static ITransformer? _model = null;

        public class FeedbackEntry
        {
            [KeyType(count: 100000)]
            public uint UserId { get; set; }

            [KeyType(count: 100000)]
            public uint ParkingSpotId { get; set; }

            public float Label { get; set; }
        }

        public class ParkingSpotScorePrediction
        {
            public float Score { get; set; }
        }

        public static void TrainModelAtStartup(IServiceProvider serviceProvider)
        {
            lock (_mlLock)
            {
                using var scope = serviceProvider.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<ParkHereDbContext>();

                // Build dataset from reservations
                var reservations = context.ParkingReservations
                    .Select(r => new FeedbackEntry
                    {
                        UserId = (uint)r.UserId,
                        ParkingSpotId = (uint)r.ParkingSpotId,
                        Label = 1f
                    })
                    .ToList();

                // Add data from reviews (higher weight for good ratings)
                var reviews = context.Reviews
                    .Where(r => r.Rating >= 4)
                    .Select(r => new FeedbackEntry
                    {
                        UserId = (uint)r.UserId,
                        ParkingSpotId = (uint)r.ParkingReservation.ParkingSpotId,
                        Label = 1.5f
                    })
                    .ToList();

                var data = reservations.Concat(reviews).ToList();

                if (!data.Any())
                {
                    _model = null;
                    return;
                }

                var trainData = _mlContext.Data.LoadFromEnumerable(data);

                var options = new MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(FeedbackEntry.UserId),
                    MatrixRowIndexColumnName = nameof(FeedbackEntry.ParkingSpotId),
                    LabelColumnName = nameof(FeedbackEntry.Label),
                    LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01,
                    Lambda = 0.025,
                    NumberOfIterations = 50,
                    C = 0.00001
                };

                var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                _model = estimator.Fit(trainData);
            }
        }

        public static float Predict(int userId, int spotId)
        {
            if (_model == null) return 0f;

            lock (_mlLock)
            {
                var predictionEngine = _mlContext.Model.CreatePredictionEngine<FeedbackEntry, ParkingSpotScorePrediction>(_model);
                var prediction = predictionEngine.Predict(new FeedbackEntry
                {
                    UserId = (uint)userId,
                    ParkingSpotId = (uint)spotId
                });

                return prediction.Score;
            }
        }
        
        public static bool IsModelAvailable() => _model != null;

        private static DateTime _lastRetrainTime = DateTime.MinValue;
        public static void TriggerRetraining(IServiceProvider serviceProvider)
        {
            // Cooldown of 30 seconds to prevent excessive retraining
            if ((DateTime.Now - _lastRetrainTime).TotalSeconds < 30) return;

            _lastRetrainTime = DateTime.Now;
            _ = Task.Run(() =>
            {
                try
                {
                    TrainModelAtStartup(serviceProvider);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error in background retraining: {ex.Message}");
                }
            });
        }
    }
}
