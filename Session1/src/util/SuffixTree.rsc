module util::SuffixTree

import Map;
import List;

public data Node = Node(list[&V] values, map[&k, Node] next);

public Node put(Node root, list[&K] suffixes, &V val) {
	suffix = head(suffixes);
	remainder = tail(suffixes);
	if (isEmpty(remainder)) {
		if (root.next[suffix]?) {
			root.next[suffix].values += [val];
		} else {
			root.next += (suffix:Node([val], ()));
		}
	} else {
		if (!root.next[suffix]?) {
			root.next += (suffix:Node([], ()));
		}
		root.next[suffix] = put(root.next[suffix], remainder, val);
	}
	return root;
}