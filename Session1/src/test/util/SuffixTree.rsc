module \test::util::SuffixTree

import IO;
import util::SuffixTree;

// Suffix construction tests

test bool addOneLineToSuffixTree() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1"], 1);
	
	expected = SuffixTree(Node([], ("1" : Node([1], ()))));
	return tree == expected;
} 

test bool addTwoLinesToSuffixTree() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1", "2"], 1);
	
	expected = SuffixTree(Node([], ("1" : Node([], ("2" : Node([1], ()))))));
	return tree == expected;
}

test bool addTwoUniqueLinesToSuffixTree() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1"], 1);
	tree = put(tree, ["2"], 2);
	
	expected = SuffixTree(Node([], ("1" : Node([1], ()), "2" : Node([2], ()))));
	return tree == expected;
}

test bool addCloneSingleLineToSuffixTree() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1"], 1);
	tree = put(tree, ["1"], 2);
	
	expected = SuffixTree(Node([], ("1" : Node([2, 1], ()))));
	return tree == expected;
}

test bool addSecondLinesWithSameSuffixToSuffixTree() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1"], 1);
	tree = put(tree, ["1", "2"], 2);
	
	expected = SuffixTree(Node([], ("1" : Node([1], ("2" : Node([2], ()))))));
	return tree == expected;
}

test bool addSecondLinesWithSameSuffixToSuffixTree() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1", "2"], 1);
	tree = put(tree, ["1", "3"], 2);
	
	expected = SuffixTree(Node([], ("1" : Node([], ("2" : Node([1], ()), "3" : Node([2], ()))))));
	return tree == expected;
}

test bool addMultipleLinesWithSameSuffixToSuffixTree() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1", "2"], 1);
	tree = put(tree, ["1", "2"], 2);
	tree = put(tree, ["1", "3"], 3);
	tree = put(tree, ["1", "3"], 4);
	
	expected = SuffixTree(Node([], ("1" : Node([], ("2" : Node([2, 1], ()), "3" : Node([4, 3], ()))))));
	return tree == expected;
}

// Linear branch cleaning tests

test bool removeSingleLineBranchesFromSuffixTreeWithoutLinearBranch() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1", "2"], 1);
	tree = put(tree, ["1", "2"], 2);
	
	tree = removeLinearBranches(tree);
	
	expected = SuffixTree(Node([], ("1" : Node([], ("2" : Node([2, 1], ()))))));
	return tree == expected;
}

test bool removeSingleLineBranchesFromSuffixTree() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1", "2"], 1);
	tree = put(tree, ["1", "2"], 2);
	tree = put(tree, ["2", "3"], 3);
	
	tree = removeLinearBranches(tree);
	
	expected = SuffixTree(Node([], ("1" : Node([], ("2" : Node([2, 1], ()))))));
	return tree == expected;
}

test bool removeSingleLineBranchesFromSuffixTreeWithBranched() {
	SuffixTree tree = SuffixTree(Node([], ()));
	tree = put(tree, ["1", "2"], 1);
	tree = put(tree, ["1", "3"], 2);
	tree = put(tree, ["2", "3"], 3);
	
	tree = removeLinearBranches(tree);
	
	expected = SuffixTree(Node([], ("1" : Node([], ("2" : Node([1], ()), "3" : Node([2], ()))))));
	return tree == expected;
}
