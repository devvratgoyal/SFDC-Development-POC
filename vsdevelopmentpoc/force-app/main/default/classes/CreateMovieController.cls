public with sharing class CreateMovieController {

    public PageReference save() {
        
        insert movieObj;
        
        return null;
    }

        
        public Movie__c movieObj{get;set;}
        transient Integer noOfMovie = 0;
        
        
        
        public CreateMovieController(){
                movieObj = new Movie__c();
        }
        
        public list<Movie__c> getMoview(){
                return null;
        }
}