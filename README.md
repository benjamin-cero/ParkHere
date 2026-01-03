# ParkHere - Smart Parking Management System

## Overview

ParkHere is a parking management solution that enables users to reserve parking spots through a mobile application while administrators oversee operations via a desktop application. The system utilizes an ASP.NET Core backend API with a SQL Server database, ensuring secure data management and real-time synchronization across platforms.

## Test Credentials

### Desktop Administrative Application
- **Username**: `desktop`
- **Password**: `test`

### Mobile User Application
- **Username**: `user`
- **Password**: `test`

### Email Service
- **Address**: parkhere.receive@gmail.com
- **Password**: ParkHere123
- **Note**: System notifications are sent from this address

---

## Application Functionality

### Mobile Application (User)

The mobile application allows users to browse available parking spots, create reservations, and manage active sessions. Users navigate through parking sectors organized by wings, with each spot displaying its type (Standard, VIP, Electric, Disabled) and availability status indicated by color coding: green for available, yellow for reserved by others, and red for inactive spots.

When creating a reservation, users select a parking spot, specify the desired time period, and enter personal information. The system calculates the total cost based on the hourly rate (3 BAM), session duration, and spot type multiplier. Upon confirmation, the reservation is created and the user receives a booking summary.

The home screen displays active reservations with real-time countdown timers and session details. Users can manage multiple concurrent reservations through a swipeable interface. Each reservation card shows the parking location, remaining time, and current price. The application also includes a history section where users can review past bookings, view final charges, and access their payment records.

### Desktop Application (Administrator)

The administrative application provides tools for managing the parking infrastructure and monitoring system operations. Administrators can oversee user accounts, configure parking sectors and wings, adjust individual spot properties, and review all reservations across the platform.

The entry approval workflow requires administrators to verify users upon arrival. When a user signals their arrival through the mobile app, the reservation appears in the admin queue for approval. This workflow ensures security and prevents unauthorized access to parking facilities.

Business analytics features provide insights into revenue trends, popular parking locations, and utilization rates. The dashboard displays monthly earnings, sector performance, and identifies the most frequently booked spot types through interactive charts and graphs.

---

## Reservation Business Logic

### Pricing Model

The base parking rate is set at 3 BAM per hour. Each spot type has an associated price multiplier that adjusts the final cost: Regular spots use a 1.0x multiplier, VIP spots apply a 1.5x multiplier, Electric spots use 1.2x, and Handicapped spots offer a reduced rate at 0.75x. The total reservation price is calculated by multiplying the hourly rate by the session duration and the appropriate spot multiplier.

### Reservation Lifecycle and Restrictions

When a user creates a reservation, the system validates spot availability and calculates the initial price. The reservation enters a "Pending" state until the user arrives at the facility. Upon arrival, the user signals through the mobile app, triggering an admin approval request. Once approved, the system records the actual start time as the originally reserved start time, regardless of when the user physically arrived. This approach ensures users are charged for their full reservation period, preventing late arrivals from reducing the expected revenue.

During an active session, the system displays a countdown timer showing the time remaining until the reserved end time. Users can extend their reservation while still within the reserved period. The extension updates the end time and recalculates the total price accordingly. However, session extensions are only permitted before the original end time expires. Once a session enters overtime, the extension option is disabled to maintain pricing integrity.

### Overtime Handling

When a user exceeds their reserved end time without exiting, the session transitions into overtime. The interface immediately reflects this change: the countdown timer displays the elapsed overtime duration in red, and the price indicator begins calculating additional charges. Overtime fees are computed using the same hourly rate and spot multiplier, but with an additional penalty factor to discourage prolonged overstays.

During overtime, users cannot extend their reservation. The only available action is to exit the parking facility, which triggers the final price calculation including all accumulated overtime charges. This restriction prevents users from retroactively converting overtime into standard reservation time at regular rates.

Upon exit, the system calculates the final amount due. If the user exits within the reserved period, they are charged the full reservation price with no refund for early departure. If exiting during overtime, the base reservation price is combined with the calculated overtime charges to determine the total payment. This policy ensures predictable revenue while maintaining fairness in billing practices.

### No-Show Debt Collection

A critical aspect of the system is the handling of no-show reservations. When a user creates a booking but fails to arrive, and the reserved end time passes without any recorded entry, the system marks the reservation as a no-show. The full cost of this missed reservation becomes an outstanding debt associated with the user's account.

The mobile application displays a warning indicator on the home screen when a user has unpaid no-show debts. This notification ensures users are aware of their financial obligations before making new reservations. When such a user attempts to book another parking spot, the system automatically adds all accumulated no-show debts to the new reservation's price. The booking confirmation displays the base price plus the debt amount separately, providing transparency in billing.

Upon payment of the new reservation, the system simultaneously settles all associated no-show debts. These previously unpaid reservations are marked as "Loan Payed" in the user's history, indicating the debt has been cleared. This automated collection mechanism ensures accountability while allowing users to continue accessing the service, unlike systems that might completely block access until debts are paid separately.

### Update and Extension Rules

Session updates follow specific restrictions to maintain system integrity. Users can only extend active reservations before reaching the original end time. The extension feature calculates the additional cost based on the added duration and updates both the reservation end time and total price. This modification occurs in real-time without creating a new booking, preserving the continuity of the parking session.

Once a session enters overtime, all update capabilities are revoked except for the exit function. This design prevents scenarios where users might attempt to legitimize overtime periods by converting them into standard reservations. The system enforces this restriction by disabling the extension button and presenting only the exit option in the user interface.

Administrative users cannot modify active sessions or completed reservations. Their role focuses on entry approval rather than reservation management. This separation ensures that pricing calculations and session timelines remain consistent with the originally agreed terms, preventing unauthorized adjustments that could affect billing accuracy.

---

## Conclusion

The ParkHere system implements a structured approach to parking management through clear business rules governing reservations, pricing, and user obligations. The debt collection mechanism addresses no-show behavior without preventing future access, while overtime restrictions ensure fair pricing for extended usage. Session extension capabilities provide flexibility during active reservations while maintaining revenue protection through time-based limitations. These policies work together to create a balanced system that serves both user convenience and operational efficiency.
