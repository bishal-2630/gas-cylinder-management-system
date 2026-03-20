# Implementation Plan: Hybrid Gas Management System

This project aims to build a hybrid gas management system for Nepal, combining official dealer stock data with crowd-sourced community reports to provide real-time availability and manage queues during shortages.

## Proposed Architecture

### Backend (Python/Django)
- **Role**: Robust API and administrative interface.
- **Key Features**: 
  - Django Rest Framework (DRF) for the core API.
  - GeoDjango (PostGIS) for spatial queries and dealer mapping.
  - Built-in admin interface for managing dealers and system audits.

### Mobile (Flutter)
- **Role**: Cross-platform mobile engagement layer.
- **Key Features**:
  - Interactive Map using `google_maps_flutter` or `flutter_map`.
  - Real-time reactivity for community sightings.
  - Integrated QR/Token system for queue management.

## Proposed Changes

### [Component] Backend
Summary: Initialize Django project, setup models for Brands, Dealers, and Sightings.

#### [NEW] [requirements.txt](file:///d:/gas%20cylinder%20management/backend/requirements.txt)
#### [NEW] [core/models.py](file:///d:/gas%20cylinder%20management/backend/core/models.py)
#### [NEW] [api/views.py](file:///d:/gas%20cylinder%20management/backend/api/views.py)

### [Component] Mobile
Summary: Initialize Flutter project and setup basic navigation and map view.

#### [NEW] [pubspec.yaml](file:///d:/gas%20cylinder%20management/mobile/pubspec.yaml)
#### [NEW] [lib/main.dart](file:///d:/gas%20cylinder%20management/mobile/lib/main.dart)

## Verification Plan

### Automated Tests
- **Backend**: Django test suite for model validation and API status codes.
  - Run: `python manage.py test` in `backend` directory.
- **Mobile**: Flutter widget and unit tests.
  - Run: `flutter test` in `mobile` directory.

### Manual Verification
1. **Official vs. Crowd Sourced**: Verify a dealer's stock update appears on the map alongside a user sighting.
2. **Geo-Fence check**: Verify users can only report sightings within a reasonable distance of a dealer.
