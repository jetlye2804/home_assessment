# Jet's Movie App

A simple movie app which used TMDB V3 API.

## Getting Started

*Disclaimer: This simple movie app is a Flutter project for assessment purpose.*

This movie app includes some features to get information about the movies:
- Now Playing: Display a grid list of movies which are now in theatres.
- Top Favorite: Display a grid list of movies, starts from the highest favorite.
- My favorite movies: Display a grid list of movies marked as "favorite"
- Search movie: Find movies using certain keywords

In every grid cell, the following information are displayed:
- Poster image
- Movie name
- Released date
- 1x Genre tag (Get the first one if multiple genre exist)
- Adult tag (Shows that the movie is NSFW/SFW)
- Language tag (in short form)
- Voting percentage

In every movie detail page, the following information are displayed:
- Banner image of the movie
- Movie name
- Movie tag line
- Movie duration
- Save to favorite list button
- Released date
- Multiple genre tags
- Adult tag (Shows that the movie is NSFW/SFW)
- Voting percentage
- Production companies
- Spoken language
- Budget amount and revenue amount

## API used
The movie information are obtained from [TMDB V3 API](https://developers.themoviedb.org/3).

## Limitation
Remove movies from favorite list is unable to implement, as the TMDB V3 API does not provide the related API to do so.