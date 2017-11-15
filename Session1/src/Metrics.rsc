module Metrics

import IO;
import List;

public data MethodMetrics = MethodMetrics(int sloc, int ccfg, int ccwi);
public data Complexity = Complexity(int low, int moderate, int high, int veryHigh);

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

public Complexity computeComplexity(int totalSLOC, list[MethodMetrics] metrics, int (MethodMetrics) cc) {
	list[MethodMetrics] lowRiskMethods = [];
	list[MethodMetrics] moderateRiskMethods = [];
	list[MethodMetrics] highRiskMethods = [];
	list[MethodMetrics] veryHighRiskMethods = [];
	for (m <- metrics) {
		if (cc(m) <= 10) {
			lowRiskMethods += m;
		} else if (cc(m) <= 20) {
			moderateRiskMethods += m;
		} else if (cc(m) <= 50) {
			highRiskMethods += m;
		} else  {
			veryHighRiskMethods += m;
		}
	}
	return Complexity(sloc(lowRiskMethods) * 100 / totalSLOC,
		sloc(moderateRiskMethods) * 100 / totalSLOC,
		sloc(highRiskMethods) * 100 / totalSLOC,
		sloc(veryHighRiskMethods) * 100 / totalSLOC
	);	
}

public void printComplexityRating(str name, Complexity complexity) {
	str rating = "--";
	if (complexity.veryHigh == 0 && complexity.high == 0 && complexity.moderate <= 25) {
		rating = "++";
	} else if (complexity.veryHigh == 0 && complexity.high <= 5 && complexity.moderate <= 30) {
		rating = "+";
	} else if (complexity.veryHigh == 0 && complexity.high <= 10 && complexity.moderate <= 40) {
		rating = "o";
	} else if (complexity.veryHigh <= 5 && complexity.high <= 15 && complexity.moderate <= 50) {
		rating = "-";
	}
	println("Complexity (<name>): <rating>");
}

public void printComplexityProfile(Complexity complexity) {
	println("Very High: <complexity.veryHigh>");
	println("High:      <complexity.high>");
	println("Mod:       <complexity.moderate>");
	println("Low:       <complexity.low>");
}
