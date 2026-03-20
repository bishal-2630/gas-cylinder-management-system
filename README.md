---
title: Gas Cylinder Management API
emoji: 🛢️
colorFrom: orange
colorTo: red
sdk: docker
pinned: false
---

# Gas Cylinder Management System - API Backend

A REST API backend for the Nepal Gas Cylinder Management System, built with Django and Django REST Framework.

## Features
- JWT Authentication for Customer & Dealer roles
- Dealer stock management API
- Community sighting reports with geo-fencing
- Role-based access control

## API Endpoints
- `POST /api/token/` - Get JWT token (Login)
- `POST /api/token/refresh/` - Refresh JWT token
- `GET /api/dealers/` - List all dealers
- `GET /api/stock/` - View stock levels
- `POST /api/sightings/` - Report a sighting
- `GET /api/profile/me/` - Get current user profile
- `POST /api/profile/signup/` - Register a new user
