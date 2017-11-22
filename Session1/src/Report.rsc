module Report

import IO;
import List;
import Metrics;

/*
 * Ratings
 */

public void printVolumeRating(int sloc) {
	rating = "--";
	if (sloc < 66000) {
		rating = "++";
	} else if (sloc < 246000) {
		rating = " +";
	} else if (sloc < 665000) {
		rating = " o";
	} else if (sloc < 1310000) {
		rating = " -";
	}
	println("Volume:           <rating>");
}

public void printDuplicationRating(SlocDup slocDup) {
	dupPercentage = 100 * slocDup.dups / slocDup.sloc;
	rating = "--";
	if (dupPercentage <= 3) {
		rating = "++";
	} else if (dupPercentage <= 5) {
		rating = " +";
	} else if (dupPercentage <= 10) {
		rating = " o";
	} else if (dupPercentage <= 20) {
		rating = " -";
	}
	println("Duplication:      <rating>");
}

public void printUnitSizeRating(MetricsDistribution distribution) {
	str rating = "--";
	if (distribution.veryHigh == 0 && distribution.high == 0 && distribution.moderate <= 25) {
		rating = "++";
	} else if (distribution.veryHigh == 0 && distribution.high <= 5 && distribution.moderate <= 30) {
		rating = " +";
	} else if (distribution.veryHigh == 0 && distribution.high <= 10 && distribution.moderate <= 40) {
		rating = " o";
	} else if (distribution.veryHigh <= 5 && distribution.high <= 15 && distribution.moderate <= 50) {
		rating = " -";
	}
	println("Unit size:        <rating>");
}

public void printComplexityRating(str name, MetricsDistribution distribution) {
	str rating = "--";
	if (distribution.veryHigh == 0 && distribution.high == 0 && distribution.moderate <= 25) {
		rating = "++";
	} else if (distribution.veryHigh == 0 && distribution.high <= 5 && distribution.moderate <= 30) {
		rating = " +";
	} else if (distribution.veryHigh == 0 && distribution.high <= 10 && distribution.moderate <= 40) {
		rating = " o";
	} else if (distribution.veryHigh <= 5 && distribution.high <= 15 && distribution.moderate <= 50) {
		rating = " -";
	}
	println("Complexity (<name>): <rating>");
}

public void printTestabilityRating(list[MethodMetrics] metrics) {
	rating = " ?";
	println("Testability:      <rating>");
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
