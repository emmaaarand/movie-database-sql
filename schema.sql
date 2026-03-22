-- Movie Database Project
-- Course assignment demonstrating relational database design and SQL queries

Drop Table If Exists MovieCrew;
Drop Table If Exists MovieReviewer;
Drop Table If Exists Movie;
Drop Table If Exists Rating;
Drop Table If Exists Reviewer;
Drop Table If Exists Position;
Drop Table If Exists Crew;
Drop Table If Exists MovieStudio;
Drop Table If Exists Genre;
Drop Table If Exists Director;



Create Table If Not Exists Director
(
	DirectorID			int				Not Null
	Constraint PK_Director_DirectorID 
		Primary Key,
	FirstName			varchar(30)		Not Null,
	LastName			varchar(30)		Not Null
	Constraint CK_Director_LastName
		Check (length(LastName) >= 3)
);

Create Table If Not Exists Genre
(
	GenreCode			int				Not Null
	Constraint PK_Genre_GenreCode
		Primary Key,
	GenreName			varchar(30)		Not Null
	Constraint UQ_Genre_GenreName
		Unique
		
);

Create Table If Not Exists MovieStudio
(
	MovieStudioID		int				Not Null		
	Constraint PK_MovieStudio_MovieStudioID
		Primary Key,
	MovieStudioName		varchar(50)		Not Null
	Constraint UQ_MovieStudio_MovieStudioName
		Unique,	
	City				varchar(30)		Not Null,
	Province			char(2)			Not Null,
	Phone				char(12)		Not Null
	Constraint UQ_MovieStudio_Phone
		Unique,	
	Email				varchar(50)		Not Null,
	ContactFirstName	varchar(30)		Not Null,
	ContactLastName		varchar(30)		Not Null
	Constraint CK_MovieStudio_ContactLastName
		Check (length(ContactLastName) >= 3)
);

Create Table If Not Exists Crew
(
	CrewID				int				Not Null			
	Constraint PK_Crew_CrewID
		Primary Key,
	FirstName			varchar(30)		Not Null,
	LastName			varchar(30)		Not Null
	Constraint CK_Crew_LastName
		Check (length(LastName) >= 3)

);

Create Table If Not Exists Position
(
	PositionID			int				Not Null		
	Constraint PK_Position_PositionID
		Primary Key,
	PositionName		varchar(40)		Not Null
	Constraint UQ_Position_PositionName
		Unique

);

Create Table If Not Exists Reviewer
(
	ReviewerID			int				Not Null		
	Constraint PK_Reviewer_ReviewerID
		Primary Key,
	FirstName			varchar(30)		Not Null,
	LastName			varchar(30)		Not Null
	Constraint CK_Reviewer_LastName
		Check (length(LastName) >= 3),
	
	Organization		varchar(50)		Not Null
	Constraint UQ_Reviewer_Organization
		Unique
);

Create Table If Not Exists Rating
(
	RatingCode			int				Not Null	
	Default 3
	Constraint CK_Rating_RatingCode 
		Check (RatingCode Between 1 and 6 )
	Constraint PK_Rating_RatingCode
		Primary Key,
	RatingDescription	varchar(50)		Not Null
	Constraint UQ_Rating_RatingDescription
		Unique
);

Create Table If Not Exists Movie
(
	MovieID				int				Not Null
	Constraint PK_Movie_MovieID
		Primary Key,
	Title				varchar(80)		Not Null,
	ReleaseDate			date			Not Null Default Current_Date,
	MovieLength			int				Not Null Default 0,
	Budget				decimal(12,2)	Not Null
	Constraint CK_Movie_Budget
		Check (Budget >= 0),
	ProjectedRevenue	decimal(12,2)	Not Null
	Constraint CK_Movie_ProjectedRevenue
		Check (ProjectedRevenue >= 0),
	DirectorID			int				Not Null
	Constraint FK_Movie_DirectorID_Director_DirectorID
		References Director (DirectorID),
	GenreCode			int				Not Null
	Constraint FK_Movie_GenreCode_Genre_GenreCode
		References Genre (GenreCode),
	MovieStudioID		int				Not Null
	Constraint FK_Movie_MovieStudioID_MovieStudio_MovieStudioID
		References MovieStudio (MovieStudioID),

	Constraint CK_Movie_ProjectedRevenue_Budget
		Check (ProjectedRevenue > Budget)
);


Create Table If Not Exists MovieReviewer
(
	ReviewerID			int				Not Null		
	Constraint FK_MovieReviewer_ReviewerID_Reviewer_ReviewerID
		References Reviewer (ReviewerID),
	MovieID				int				Not Null
	Constraint FK_MovieReviewer_MovieID_Movie_MovieID
		References Movie (MovieID),
	RatingCode			int				Not Null
	Constraint FK_MovieReviewer_RatingCode_Rating_RatingCode
		References Rating (RatingCode),
	Constraint PK_MovieReviewer_ReviewerID_MovieID
		Primary Key (ReviewerID, MovieID)
);

Create Table If Not Exists MovieCrew
(
	MovieID				int				Not Null
	Constraint FK_MovieCrew_MovieID_Movie_MovieID
		References Movie (MovieID),
	CrewID				int				Not Null
	Constraint FK_MovieCrew_CrewID_Crew_CrewID
		References Crew (CrewID),
	Wage				decimal(7,2)	Not Null
	Constraint CK_MovieCrew_Wage
		Check (Wage > 0),
	PositionID 			int				Not Null
	Constraint FK_MovieCrew_PositionID_Position_PositionID
		References Position (PositionID),
	Constraint PK_MovieCrew_MovieID_CrewID
	Primary Key (MovieID, CrewID)

);

-- 2.	INSERT a new MovieCrew record 

Begin Transaction;
Select 		MovieID, CrewID, Wage, PositionID
From 		MovieCrew;

Insert Into MovieCrew(MovieID, CrewID, Wage, PositionID)
Select 		5, 2, Max(Wage), 1
From 		MovieCrew
Where		MovieID = 5;

Select 		MovieID, CrewID, Wage, PositionID
From 		MovieCrew;
Rollback Transaction;

-- 3.	UPDATE the Wage of the MovieCrew 'SQL, A Romantic Journey' 10%

Begin Transaction;
Select 		MovieCrew.MovieID, MovieCrew.Wage 
From 		MovieCrew;

Update 		MovieCrew
Set 		Wage = Wage * 1.10
From 		Movie
Where 		Movie.Title = 'SQL, A Romantic Journey' and
			MovieCrew.MovieID = Movie.MovieID;

Select 		MovieCrew.MovieID, MovieCrew.Wage 
From 		MovieCrew;
Rollback Transaction;

-- 4.	DELETE all the MovieReviewer records whose RatingCode is less than the average 

Begin Transaction;

Select RatingCode
From MovieReviewer;

Delete From MovieReviewer 
Where 		RatingCode < 
			(Select AVG(RatingCode)
			From MovieReviewer);
			
Select RatingCode
From MovieReviewer;

Rollback Transaction;

