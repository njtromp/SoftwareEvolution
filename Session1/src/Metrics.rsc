module Metrics

import IO;
import List;

public Rating PLUS_PLUS = 2;
public Rating PLUS = 1;
public Rating ZERO = 0;
public Rating MIN = -1;
public Rating MIN_MIN = -2;

public alias CC = int;
public alias SLOC = int;
public alias DUPS = int;
public alias Rating = int;
public alias ClassName = str;
public alias MethodName = str;

public data MethodMetrics = MethodMetrics(str method, bool isTest, SLOC sloc, int ccfg, int ccwi)
							| MethodMetrics(str method, bool isTest, SLOC sloc, int ccfg, int ccwi, int asserts);
public data MetricsDistribution = MetricsDistribution(int low, int moderate, int high, int veryHigh);
public data SlocDup = SlocDup(SLOC sloc, DUPS dups);
public data Ratings = Ratings(Rating volume, Rating duplication, Rating unitSize, Rating ccfg, Rating ccwi, Rating testability);

public Rating slocRating(SLOC sloc) {
	if (sloc < 66000) {
		return PLUS_PLUS;
	} else if (sloc < 246000) {
		return PLUS;
	} else if (sloc < 665000) {
		return ZERO;
	} else if (sloc < 1310000) {
		return MIN;
	}
	return MIN_MIN;
}

public Rating duplicationRating(SlocDup slocDup) {
	dupPercentage = 100 * slocDup.dups / slocDup.sloc;
	if (dupPercentage <= 3) {
		return PLUS_PLUS;
	} else if (dupPercentage <= 5) {
		return PLUS;
	} else if (dupPercentage <= 10) {
		return ZERO;
	} else if (dupPercentage <= 20) {
		return MIN;
	}
	return MIN_MIN;
}

public Rating distributionRating(MetricsDistribution distribution) {
	if (distribution.veryHigh == 0 && distribution.high == 0 && distribution.moderate <= 25) {
		return PLUS_PLUS;
	} else if (distribution.veryHigh == 0 && distribution.high <= 5 && distribution.moderate <= 30) {
		return PLUS;
	} else if (distribution.veryHigh == 0 && distribution.high <= 10 && distribution.moderate <= 40) {
		return ZERO;
	} else if (distribution.veryHigh <= 5 && distribution.high <= 15 && distribution.moderate <= 50) {
		return MIN;
	}
	return MIN_MIN;
}

public Rating testabilityRating(SLOC totalSLOC, list[MethodMetrics] metrics) {
	testSloc = sloc([m|m<-metrics, m.isTest]);
	totalSloc = sloc([m|m<-metrics, !m.isTest]);
	testPercentage = 1.0 * testSloc / totalSloc;
	if (testPercentage <= 0.2) {
		return MIN_MIN;
	} else if (testPercentage <= 0.6) {
		return MIN;
	} else if (testPercentage <= 0.8) {
		return ZERO;
	} else if (testPercentage <= 0.95) {
		return PLUS;
		}
	return PLUS_PLUS;
}

public MetricsDistribution computeUnitSize(SLOC totalSLOC, list[MethodMetrics] metrics) {
	list[MethodMetrics] lowMethods = [];
	list[MethodMetrics] moderateMethods = [];
	list[MethodMetrics] highMethods = [];
	list[MethodMetrics] veryHighMethods = [];
	for (m <- metrics) {
		if (m.sloc <= 15) {
			lowMethods += m;
		} else if (m.sloc <= 30) {
			moderateMethods += m;
		} else if (m.sloc <= 60) {
			highMethods += m;
		} else  {
			veryHighMethods += m;
		}
	}
	totalSLOC = sloc(metrics);
	return MetricsDistribution(sloc(lowMethods) * 100 / totalSLOC,
		sloc(moderateMethods) * 100 / totalSLOC,
		sloc(highMethods) * 100 / totalSLOC,
		sloc(veryHighMethods) * 100 / totalSLOC
	);	
}

public MetricsDistribution computeComplexity(list[MethodMetrics] metrics, int (MethodMetrics) cc) {
	list[MethodMetrics] lowMethods = [];
	list[MethodMetrics] moderateMethods = [];
	list[MethodMetrics] highMethods = [];
	list[MethodMetrics] veryHighMethods = [];
	for (m <- metrics) {
		if (cc(m) <= 10) {
			lowMethods += m;
		} else if (cc(m) <= 20) {
			moderateMethods += m;
		} else if (cc(m) <= 50) {
			highMethods += m;
		} else  {
			veryHighMethods += m;
		}
	}
	totalSLOC = sloc(metrics);
	return MetricsDistribution(sloc(lowMethods) * 100 / totalSLOC,
		sloc(moderateMethods) * 100 / totalSLOC,
		sloc(highMethods) * 100 / totalSLOC,
		sloc(veryHighMethods) * 100 / totalSLOC
	);	
}

public int sloc(list[MethodMetrics] metrics) {
	return ( 0 | it + m.sloc | m <-metrics);
}


public int asserts(list[MethodMetrics] metrics) {
	return ( 0 | it + asserts | m <-metrics, MethodMetrics(_, _, _, _, _, asserts) := m);
}
