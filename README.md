KAEMusic: Cross-Platform Mobile Music Application
Software Requirements Specification (SRS)
Version: 2.0
Status: Draft — Pending Approval
1. Introduction
________________________________________1.1 Project Overview
KAEMusic is a cross-platform mobile application for music streaming and management developed using the Flutter framework. The system allows users to create personalized playlists, search for tracks, and listen to them through a modern mobile interface, interacting with a Java-based backend.
1.2 Purpose
This document defines the functional and non-functional requirements for the development of the KAEMusic mobile application. It is prepared to align the project architecture with the university curriculum and obtain approval before development begins.
1.3 Scope
●	User registration, authentication, and profile management.
●	Playlist management system (CRUD: Create, Read, Update, Delete).
●	Audio streaming with background playback support.
●	Music search by artist, genre, and title.
●	Data synchronization between the mobile client and the backend.
2. Technology Stack
________________________________________
Layer	Technology
Mobile Frontend	Flutter (Dart)
Backend	Java 17+ (Spring Boot)
Database	PostgreSQL (Main), SQLite (Local Cache)
Architecture	REST API (JSON)
Authentication	Spring Security + JWT
Audio Library	just_audio / audioplayers (Flutter packages)
3. Functional Requirements
________________________________________3.1 User Management
●	Users can create an account using Email and password.
●	Secure authentication and session management using JWT.
●	View and edit personal profiles (username, avatar).
3.2 Playlist Management
●	Create new playlists with unique names and descriptions.
●	Add and remove tracks from playlists.
●	Ability to mark tracks as "Favorites" (Liked Songs).
3.3 Music Player
●	Standard controls: Play, Pause, Skip Next/Previous.
●	Background playback support and lock screen controls.
●	Shuffle and Repeat playback modes.
3.4 Search & Discovery
●	Global search by song title, artist, or album.
●	Filter tracks by genre and category.
4. Data Model Overview
________________________________________
Entity	Key Attributes	Relationships
User	id, username, email, passwordHash, role	Has many Playlists
Track	id, title, artist, album, genre, duration, streamUrl	Can belong to many Playlists
Playlist	id, name, userId, createdAt	Belongs to User, contains Tracks
5. Non-Functional Requirements
●	________________________________________Performance: API response time should not exceed 500ms for 95% of requests.
●	Security: Password hashing using BCrypt on the server side.
●	Usability: Interface must follow Material Design 3 principles and be responsive.
●	Reliability: Ensure player state is maintained during temporary network loss.
6. User Stories
●	________________________________________As a user, I want to listen to music in the background so I can use other apps simultaneously.
●	As a user, I want to create themed playlists to quickly find music for different moods.
●	As a user, I want to see album art to navigate my library more easily.
