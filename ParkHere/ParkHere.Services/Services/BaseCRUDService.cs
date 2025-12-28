using ParkHere.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;
using ParkHere.Model.Responses;
using ParkHere.Model.Requests;
using ParkHere.Model.SearchObjects;
using System.Linq;
using MapsterMapper;
using ParkHere.Services.Interfaces;

namespace ParkHere.Services.Services
{
    public abstract class BaseCRUDService<T, TSearch, TEntity, TInsert, TUpdate>
    : BaseService<T, TSearch, TEntity>, ICRUDService<T, TSearch, TInsert, TUpdate>
    where T : class where TSearch : BaseSearchObject where TEntity : class, new() where TInsert : class where TUpdate : class
    {

        public BaseCRUDService(ParkHereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }


        public virtual async Task<T> CreateAsync(TInsert request)
        {
            var entity = new TEntity(); // kreira grad
            MapInsertToEntity(entity, request); // mapiras name desc..
            _context.Set<TEntity>().Add(entity); // dodas u bazzu

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        protected virtual async Task BeforeInsert(TEntity entity, TInsert request)
        {

        }


        protected virtual TEntity MapInsertToEntity(TEntity entity, TInsert request)
        {
            return _mapper.Map(request, entity);
        }

        public virtual async Task<T?> UpdateAsync(int id, TUpdate request)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return null;

            await BeforeUpdate(entity, request);

            MapUpdateToEntity(entity, request);
            
            await AfterUpdate(entity, request);

            await _context.SaveChangesAsync();
            
            return MapToResponse(entity);
        }

        protected virtual async Task BeforeUpdate(TEntity entity, TUpdate request)
        {

        }

        protected virtual async Task AfterUpdate(TEntity entity, TUpdate request)
        {

        }

        protected virtual void MapUpdateToEntity(TEntity entity, TUpdate request)
        {
            _mapper.Map(request, entity);
        }

        public virtual async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return false;

            await BeforeDelete(entity);

            _context.Set<TEntity>().Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        protected virtual async Task BeforeDelete(TEntity entity)
        {

        }

    }
}