module Metrics

import IO;
import List;

public alias CC = int;
public alias SLOC = int;
public alias DUPS = int;
public alias ClassName = str;
public alias MethodName = str;

public data MethodMetrics = MethodMetrics(bool isTest, SLOC sloc, int ccfg, int ccwi, int asserts);
public data Method = Methond(MethodName name, SLOC sloc, CC ccfg, CC ccwi);
public data Class = Class(ClassName name, bool isTest, SLOC sloc, list[Method] methods);
public data Project = Project(list[Class] classes);
public data MetricsDistribution = MetricsDistribution(int low, int moderate, int high, int veryHigh);
public data SlocDup = SlocDup(SLOC sloc, DUPS dups);

public int sloc(list[MethodMetrics] metrics) {
	return ( 0 | it + m.sloc | m <-metrics);
}

public int asserts(list[MethodMetrics] metrics) {
	return ( 0 | it + m.asserts | m <-metrics);
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
