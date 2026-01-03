# ParkHere - Smart Parking Management System

## Overview

ParkHere is a comprehensive parking management solution designed to streamline the parking reservation process for both end-users and administrators. The system consists of two primary applications: a mobile application for users to browse, reserve, and manage parking spots, and a desktop administrative application for managing parking infrastructure, monitoring reservations, and generating business analytics.

## System Architecture

The ParkHere ecosystem is built on a three-tier architecture:

- **Backend API**: ASP.NET Core Web API providing RESTful endpoints for all business logic
- **Mobile Application**: Flutter-based cross-platform application for iOS and Android users
- **Desktop Application**: Flutter-based administrative dashboard for Windows/MacOS/Linux

All applications communicate with a centralized SQL Server database through the backend API, ensuring data consistency and security across the platform.

## Test Credentials

For evaluation and testing purposes, the following credentials have been configured:

### Desktop Administrative Application
- **Username**: `desktop`
- **Password**: `test`

### Mobile User Application
- **Username**: `user`
- **Password**: `test`

### Email Notifications
The system uses an automated email service for sending reservation confirmations and notifications:
- **Email Address**: parkhere.receive@gmail.com
- **Email Password**: ParkHere123
- **Purpose**: All system notifications (booking confirmations, payment receipts, session updates) are sent from this address

---

## Mobile Application - User Features

The mobile application serves as the primary interface for end-users to interact with the parking system. Below is a detailed breakdown of all available functionalities:

### 1. Authentication & Registration

**Registration Process:**
- New users can create an account by providing personal information including first name, last name, email address, username, and password
- The system validates email format and username uniqueness during registration
- Upon successful registration, users are automatically logged in and redirected to the home screen

**Login Process:**
- Existing users authenticate using their username and password
- The system maintains user sessions using JWT tokens for secure API communication
- Invalid credentials trigger clear error messages to guide users

### 2. Home Screen - Active Reservations Dashboard

The home screen serves as the central hub for managing active parking sessions and upcoming reservations.

**Current Session Display:**
- Shows real-time information about active parking sessions
- Displays countdown timer until reservation end time
- Shows current parking spot details (sector, wing, spot number, type)
- Real-time price calculation based on reserved duration

**Multiple Reservation Support:**
- Users can have multiple active reservations simultaneously
- A horizontal page view allows swiping between different reservations
- Each reservation card displays comprehensive details about that specific booking

**Session Status Indicators:**
- **Pending**: Reservation created but user has not yet arrived at the parking facility
- **Arrived**: User has checked in at the parking facility (requires admin approval)
- **Active**: Parking session is currently running with real-time countdown
- **Overtime**: User has exceeded their reserved time (timer turns red, displaying overtime duration)
- **Completed**: Session has ended and payment has been processed

**Reservation Actions:**

*Extend Session:*
- Available during active sessions before overtime begins
- Allows users to add additional time to their current reservation
- Dynamically recalculates the total price based on the extended duration
- Updates the reservation in real-time without creating a new booking

*Exit Parking:*
- Available once the user has arrived and is actively parked
- Triggers the end of the parking session by setting the actual end time
- If exiting during the reserved period: charges the full reserved amount (no refunds for early exit)
- If exiting during overtime: calculates additional charges based on overtime duration multiplied by the spot's price multiplier as a penalty
- Updates the final price and marks the reservation as completed

**Debt Notification System:**
- If a user has unpaid no-show reservations (booked but never arrived), a yellow warning icon appears on the home screen
- Tapping the warning displays detailed information about outstanding debts
- Accumulated debt from missed reservations is automatically added to the next booking
- Once the new reservation is paid, all associated no-show debts are settled and marked as "Loan Payed" in history

### 3. Parking Explorer - Browse and Reserve Spots

The Parking Explorer screen provides a comprehensive view of all available parking infrastructure.

**Sector Selection:**
- Users can browse different parking sectors (e.g., A1, A2, A3)
- Each sector displays its total capacity and current availability
- Visual indicators show active vs. inactive sectors

**Parking Spot Display:**
- Organized by wings (Left Wing, Right Wing) within each sector
- Each parking spot shows:
  - Spot number and type (Standard, VIP, Electric, Disabled)
  - Current availability status
  - Price multiplier for that spot type
  - Real-time reservation status

**Spot Status Color Coding:**
- **Green**: Available for immediate booking
- **Yellow**: Currently reserved by another user
- **Red**: Spot is inactive or unavailable
- **Blue**: User's own active reservation

**Booking Process:**
- Tap any available (green) spot to open the booking modal
- Select desired start date and time
- Select desired end date and time
- System displays:
  - Base price calculation (duration × hourly rate × spot type multiplier)
  - Any accumulated debt from previous no-shows (shown as "+ X debt")
  - Total price including all charges
- Enter contact information (first name, last name)
- Confirm booking to create the reservation
- Spot immediately changes color to reflect its reserved status

**Intelligent Recommendations:**
- The system uses machine learning to analyze user booking patterns
- Frequently booked spot types and locations are identified
- Recommended spots are highlighted prominently on the dashboard
- "Quick Book" options for favorite spots streamline the reservation process

### 4. Reservation History

**Comprehensive Booking Records:**
- Displays all past and current reservations in chronological order
- Each entry shows:
  - Parking spot details (sector, wing, number, type)
  - Reserved time range (start and end times)
  - Actual arrival and exit times (if applicable)
  - Original price and final price (including any overtime charges)
  - Payment status and debt settlement information

**Status Indicators:**
- **Completed**: Successfully paid reservations
- **No-Show**: Reservations where the user never arrived (highlighted in yellow)
- **Loan Payed**: Previous no-show debts that have been settled through subsequent bookings
- **Overtime**: Reservations where the user exceeded their reserved time

**Price Breakdown:**
- Shows base reservation price
- Displays any overtime charges separately
- Indicates debt payments included in the final amount
- Provides full transparency on all charges

### 5. Reviews and Feedback

**Submitting Reviews:**
- Users can leave reviews for completed parking sessions
- Rating system (1-5 stars) for overall experience
- Text feedback field for detailed comments
- Reviews are associated with specific reservations and parking spots

**Viewing Reviews:**
- Users can view their own submitted reviews
- Historical review data helps users track their parking experiences

### 6. Profile Management

**Account Information:**
- View and edit personal details (first name, last name, email)
- Change password functionality with validation
- Profile picture upload and management
- Account creation date and user statistics

**Settings and Preferences:**
- Notification preferences for booking confirmations
- App theme and display options
- Language preferences

---

## Desktop Application - Administrative Features

The desktop administrative application provides comprehensive tools for managing the entire parking infrastructure, monitoring operations, and analyzing business performance.

### 1. Authentication

**Admin Login:**
- Secure authentication using admin credentials
- Role-based access control ensures only administrators can access the desktop application
- Session management with automatic logout for security

### 2. Dashboard Overview

**Key Performance Indicators:**
- Total revenue generated across all parking sectors
- Current occupancy rates and utilization statistics
- Number of active reservations and users
- Real-time system health monitoring

### 3. User Management

**User Directory:**
- Comprehensive list of all registered users in the system
- Advanced search functionality to filter users by:
  - Username
  - Email address
  - First name / Last name
  - Registration date
  - Account status (active/inactive)

**User Details and Actions:**
- View complete user profiles including:
  - Personal information
  - Registration date and last login
  - Total number of reservations
  - Payment history and outstanding debts
  - Review history
- Edit user information if corrections are needed
- Activate or deactivate user accounts
- Reset user passwords (security feature for account recovery)

**User Creation:**
- Administrators can manually create new user accounts
- Assign appropriate roles (regular user or admin)
- Set initial passwords for new accounts

### 4. Parking Infrastructure Management

**Sector Management:**
- View all parking sectors in the system
- Create new parking sectors with custom attributes
- Edit existing sector details (name, capacity, location)
- Activate or deactivate entire sectors
- Monitor sector-level occupancy and revenue

**Wing Management (within each Sector):**
- Each sector contains multiple wings (e.g., Left Wing, Right Wing)
- Create new wings within a sector
- Edit wing properties (name, capacity)
- Activate or deactivate individual wings
- Visual indicators show wing status (active/inactive)

**Parking Spot Management:**
- Detailed view of all individual parking spots across all sectors and wings
- For each spot, administrators can:
  - View current status (available, reserved, inactive)
  - See spot type (Standard, VIP, Electric, Disabled)
  - Edit spot properties (number, type)
  - Change the spot's type to adjust pricing strategy
  - Activate or deactivate individual spots for maintenance
  - View reservation history for that specific spot

**Spot Type Configuration:**
- Define different parking spot types with unique characteristics:
  - Standard: Base rate parking (multiplier: 1.0x)
  - VIP: Premium parking with additional amenities (multiplier: 1.5x)
  - Electric: Spots with EV charging stations (multiplier: 1.3x)
  - Disabled: Accessible parking for disabled users (multiplier: 1.0x)
- Price multipliers automatically adjust reservation costs based on spot type

### 5. Reservation Oversight

**Reservation List:**
- Comprehensive view of all reservations (past, current, future) across the entire system
- Advanced filtering options:
  - Filter by user (username or user ID)
  - Filter by parking spot (sector, wing, spot number)
  - Filter by date range (start date, end date)
  - Filter by reservation status (pending, active, completed, no-show)
  - Filter by payment status (paid, unpaid)

**Reservation Details:**
- Each reservation entry displays:
  - User information (name, username)
  - Parking spot details (full location path)
  - Reserved time range
  - Actual arrival time (null if user never arrived)
  - Actual exit time (null if still parked or never arrived)
  - Price breakdown (base price, overtime charges, debt settlements)
  - Payment status
  - Session status

**Entry Approval Workflow:**
- When a user arrives at the parking facility, they signal their arrival through the mobile app
- The reservation appears in the administrator's pending approvals queue
- Administrator verifies the user's identity and reservation details
- Upon approval:
  - The system sets the `ActualStartTime` to the originally reserved start time (not the actual arrival time)
  - This ensures users are charged for their full reservation period, even if they arrive late
  - The parking session transitions from "Pending" to "Active"
  - The user's mobile app updates to show the active session with countdown timer

**Exit Processing:**
- Exit is automated upon payment completion
- Administrators can monitor when users exit
- The system automatically calculates final charges including any overtime penalties
- No manual exit approval is required from administrators

### 6. City Management

**City Directory:**
- Manage all cities/locations where parking facilities are available
- Add new cities to expand service coverage
- Edit city information (name, region, country)
- Deactivate cities to temporarily suspend operations in certain locations
- View statistics for each city (number of sectors, total revenue)

**City Details:**
- Link parking sectors to specific cities
- Monitor city-level occupancy and performance
- Generate city-specific reports

### 7. Review Management

**Review Monitoring:**
- View all user-submitted reviews across the platform
- Filter reviews by:
  - Rating (1-5 stars)
  - User
  - Parking spot or sector
  - Date range
  - Review status (published, flagged, removed)

**Review Moderation:**
- Read detailed review content and context
- Flag inappropriate or spam reviews
- Remove reviews that violate platform policies
- Respond to user feedback (if response system is implemented)

**Review Analytics:**
- Identify trends in user satisfaction
- Spot problematic parking spots or sectors receiving consistently low ratings
- Use feedback to improve service quality

### 8. Business Analytics Dashboard

The Business Analytics section provides comprehensive insights into the financial and operational performance of the parking system.

**Revenue Metrics:**
- **Total Revenue**: Cumulative earnings across all reservations and sectors
- **Monthly Revenue Trends**: Line chart displaying revenue over a rolling 12-month period
- **Earnings by Sector**: Breakdown of which parking sectors generate the most revenue
- **Earnings by Spot Type**: Comparison of revenue from Standard vs. VIP vs. Electric vs. Disabled spots

**Utilization Metrics:**
- **Most Popular Parking Spot**: Identifies the single most frequently booked spot
- **Most Popular Spot Type**: Shows which type of spot (Standard, VIP, Electric, Disabled) is booked most often
- **Most Popular Wing**: Indicates whether Left Wing or Right Wing receives more bookings
- **Most Popular Sector**: Identifies the highest-demand parking sector

**Operational Insights:**
- **Occupancy Rates**: Percentage of spots currently booked vs. available
- **Average Session Duration**: Mean length of parking sessions
- **No-Show Rate**: Percentage of reservations where users never arrived
- **Overtime Frequency**: How often users exceed their reserved time

**Visual Data Presentation:**
- Interactive charts and graphs (bar charts, line charts, pie charts)
- Date range selectors to analyze specific time periods
- Export functionality for generating reports
- Real-time data updates

### 9. System Administration

**Role Management:**
- Assign and modify user roles (user vs. administrator)
- Control access permissions for different features
- Audit trail for role changes

**System Settings:**
- Configure base parking rates (e.g., 3 BAM per hour)
- Adjust overtime penalty multipliers
- Set maximum reservation durations
- Configure email notification templates
- Manage automated email service credentials

**Data Management:**
- Database backup and recovery options
- Data export for compliance and reporting
- System logs and activity monitoring

---

## Technical Specifications

### Backend API (ASP.NET Core)
- **Framework**: .NET 6/7/8
- **Database**: SQL Server with Entity Framework Core
- **Authentication**: JWT (JSON Web Tokens)
- **Architecture**: Clean Architecture with separate layers for API, Core Business Logic, and Data Access
- **Email Service**: SMTP integration for automated notifications
- **Machine Learning**: ML.NET for parking recommendation system

### Mobile Application (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: Provider pattern for reactive state management
- **HTTP Client**: Dio for API communication
- **Local Storage**: SharedPreferences for caching user sessions
- **Supported Platforms**: iOS and Android

### Desktop Application (Flutter)
- **Framework**: Flutter 3.x (Desktop)
- **UI Components**: Custom widgets with consistent design system
- **Charts**: fl_chart library for data visualization
- **Supported Platforms**: Windows, macOS, Linux

---

## Business Logic Details

### Pricing System

**Base Pricing:**
- Standard hourly rate: 3 BAM per hour
- Price calculated as: `Duration (hours) × Hourly Rate × Spot Type Multiplier`

**Spot Type Multipliers:**
- Standard: 1.0x (base rate)
- VIP: 1.5x (50% premium)
- Electric: 1.3x (30% premium)
- Disabled: 1.0x (base rate, accessible parking)

**Overtime Penalties:**
- When users exceed their reserved end time, overtime charges apply
- Overtime rate: `Overtime Duration (hours) × Hourly Rate × Spot Type Multiplier × Penalty Multiplier`
- Penalty multiplier is typically higher than the standard multiplier to discourage prolonged overstays
- Overtime charges are added to the base reservation price

**No-Show Debt Collection:**
- If a user books a reservation but never arrives (no actual start time recorded), and the reservation end time has passed, it is marked as a "no-show"
- The full cost of the no-show reservation becomes a debt
- When the user makes their next reservation, all accumulated no-show debts are automatically added to the new reservation price
- Once the new reservation is paid, all associated no-show debts are marked as settled
- This ensures accountability while giving users the opportunity to use the service again

### Reservation Lifecycle

1. **Creation**: User selects a spot, time range, and confirms booking. System validates availability and calculates price including any debts.

2. **Pending**: Reservation exists but user has not yet arrived. User can cancel without penalty (if cancellation is implemented).

3. **Arrival**: User arrives at parking facility and signals arrival through mobile app. Admin reviews and approves entry.

4. **Active**: Upon admin approval, `ActualStartTime` is set to the reserved start time. Session timer begins counting down to the reserved end time.

5. **Extend (Optional)**: While still within the reserved period, user can extend the reservation. Price is recalculated and the end time is updated.

6. **Normal Exit**: User exits before or exactly at the reserved end time. Final price equals the originally reserved price (no refund for early exit).

7. **Overtime Exit**: User exits after the reserved end time. System calculates overtime charges and adds them to the base price.

8. **Payment**: Final price (base + overtime + debt) is processed. Reservation is marked as paid and completed.

9. **No-Show**: If the reserved end time passes and the user never arrived, reservation is marked as a no-show and becomes a debt.

### Recommendation System

The parking recommendation engine uses machine learning (ML.NET) to analyze user behavior patterns:

- **Data Collection**: User booking history (spot types, sectors, wings, times)
- **Pattern Recognition**: Identifies frequently booked spot types and locations
- **Recommendation Generation**: Suggests spots similar to the user's historical preferences
- **Display**: Recommended spots appear prominently on the home screen and parking explorer
- **Continuous Learning**: Model is retrained periodically with new booking data to improve accuracy

---

## Installation and Deployment

### Backend API Setup
1. Clone the repository
2. Configure database connection string in `appsettings.json`
3. Run Entity Framework migrations: `dotnet ef database update`
4. Configure SMTP settings for email service
5. Run the API: `dotnet run`

### Mobile Application Setup
1. Ensure Flutter SDK is installed (3.x or higher)
2. Navigate to the mobile app directory
3. Run `flutter pub get` to install dependencies
4. Configure API endpoint in the application settings
5. Run `flutter run` to launch on connected device/emulator

### Desktop Application Setup
1. Ensure Flutter SDK with desktop support is installed
2. Navigate to the desktop app directory
3. Run `flutter pub get` to install dependencies
4. Configure API endpoint in the application settings
5. Run `flutter run -d windows` (or macos/linux) to launch

---

## Conclusion

ParkHere represents a fully-featured parking management ecosystem that addresses the needs of both end-users and administrators. The mobile application provides users with an intuitive interface to discover, reserve, and manage parking sessions with real-time updates and intelligent recommendations. The desktop administrative application offers comprehensive tools for infrastructure management, operational oversight, and business intelligence.

The system's robust pricing model, including dynamic overtime calculations and automated debt collection for no-shows, ensures fair and transparent billing. The entry approval workflow maintains security while the automated exit process streamlines operations. Combined with machine learning-powered recommendations and detailed analytics, ParkHere delivers a modern, efficient parking management solution.

For testing and evaluation purposes, please use the provided credentials to explore both the user-facing mobile application and the administrative desktop application. The email service (parkhere.receive@gmail.com) can be monitored to verify notification delivery throughout the reservation lifecycle.
