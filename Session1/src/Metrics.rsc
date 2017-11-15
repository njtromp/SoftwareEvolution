module Metrics

import IO;
import List;

public data MethodMetrics = MethodMetrics(int sloc, int ccfg, int ccwi);
public data MetricsDistribution = MetricsDistribution(int low, int moderate, int high, int veryHigh);

public int sloc(list[MethodMetrics] metrics) {
	return ( 0 | it + m.sloc | m <-metrics);
}

public void printVolumeRating(str name, int sloc) {
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
	println("Volume (<name>):       <rating>");
}

public MetricsDistribution computeUnitSize(int totalSLOC, list[MethodMetrics] metrics) {
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
	return MetricsDistribution(sloc(lowMethods) * 100 / totalSLOC,
		sloc(moderateMethods) * 100 / totalSLOC,
		sloc(highMethods) * 100 / totalSLOC,
		sloc(veryHighMethods) * 100 / totalSLOC
	);	
}

public MetricsDistribution computeComplexity(int totalSLOC, list[MethodMetrics] metrics, int (MethodMetrics) cc) {
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
	return MetricsDistribution(sloc(lowMethods) * 100 / totalSLOC,
		sloc(moderateMethods) * 100 / totalSLOC,
		sloc(highMethods) * 100 / totalSLOC,
		sloc(veryHighMethods) * 100 / totalSLOC
	);	
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

public void printComplexityProfile(MetricsDistribution distribution) {
	println("Very High: <distribution.veryHigh>");
	println("High:      <distribution.high>");
	println("Mod:       <distribution.moderate>");
	println("Low:       <distribution.low>");
}
