module Report

import IO;
import List;
import Metrics;

/*
 * Ratings
 */
 
 public void printProjectRating(Ratings ratings) {
 	projectRating = (ratings.volume + ratings.duplication + ratings.unitSize+ ratings.ccfg + ratings.testability ) / 5;
	println("Project:          <rating(projectRating)>");
 }

public void printVolumeRating(Rating slocRating) {
	println("Volume:           <rating(slocRating)>");
}

public void printDuplicationRating(Rating dupRating) {
	println("Duplication:      <rating(dupRating)>");
}

public void printUnitSizeRating(Rating unitSizeRating) {
	println("Unit size:        <rating(unitSizeRating)>");
}

public void printComplexityRating(str name, Rating ccRating) {
	println("Complexity (<name>): <rating(ccRating)>");
}

public void printTestabilityRating(Rating testabilityRating) {
	println("Testability:      <rating(testabilityRating)>");
}

/*
 * Profiles
 */

public void printVolumeProfile(SLOC sloc) {
	println("Lines of code [<sloc>]");
}

public void printDuplicationProfile(SlocDup slocDup) {
	println("Number of duplicate lines [<slocDup.dups>]");
}

public void printComplexityProfile(MetricsDistribution distribution) {
	println("Very High: <distribution.veryHigh>");
	println("High:      <distribution.high>");
	println("Mod:       <distribution.moderate>");
	println("Low:       <distribution.low>");
}

public void printTestabilityProfile(list[MethodMetrics] metrics) {
	testSloc = sloc([m|m<-metrics, m.isTest]);
	totalSloc = sloc([m|m<-metrics, !m.isTest]);
	println("Lines (test/production) <100 * testSloc / totalSloc>%");
	println("Number of asserts [<asserts(metrics)>]");
}

/*
 * Helpers
 */

private str rating(int rating) {
	switch (rating) {
		case PLUS_PLUS : return "++";
		case PLUS : return " +";
		case ZERO : return " 0";
		case MIN : return " -";
		default : return "--";
	}
}
 

