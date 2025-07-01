# ProfileHub - Flutter User Management App

ProfileHub is a comprehensive user management application built with Flutter that enables administrators to manage user profiles, analyze demographic data, and generate reports. The app features CRUD operations, real-time analytics, and PDF export capabilities.

# Features
 ## User Management

        Create, view, edit, and delete user profiles

        Form validation with age verification (18-80 years)

        Hobby tagging system with multi-select

        Location-based filtering (Rajkot as default city)

## Advanced Analytics

        Real-time gender distribution visualization

        Age segmentation (Under 25, 25-35, Above 35)

        Hobby popularity rankings with percentage metrics

        Demographic data visualization
        
## Profile Operations

        PDF generation with timestamps

        Download history tracking

        Favorite user system

        REST API integration





# Dependencies

    provider - State management
    
    pdf - PDF generation
    
    http - REST API integration
    
    intl - Date formatting
    
    charts_flutter - Data visualization



# Project Structure

    lib/
    ├── models/
    │   ├── user_model.dart
    │   └── hobby_model.dart
    ├── services/
    │   ├── api_service.dart
    │   └── pdf_service.dart
    ├── screens/
    │   ├── dashboard_screen.dart
    │   ├── user_list_screen.dart
    │   ├── profile_screen.dart
    │   ├── analytics_screen.dart
    │   └── add_user_screen.dart
    ├── widgets/
    │   ├── user_card.dart
    │   ├── age_chart.dart
    │   └── hobby_chart.dart
    └── main.dart



# License 

Distributed under the MIT License. See LICENSE for more information.



# Contact

    Mohil Parmar (Devloper) - mohilparmar1526@gmail.com
    
    Project Link: https://github.com/Mohil0003/Profile_Hub


# Acknowledgements

    Flutter - Beautiful native apps in record time
    
    Font Awesome - The iconic SVG, font, and CSS toolkit
    
    Provider - State management solution
