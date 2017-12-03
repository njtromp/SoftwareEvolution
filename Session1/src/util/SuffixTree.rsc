module util::SuffixTree

import Map;
import List;

public data Node = Node(list[&V] keys, map[&k, Node] next);

public Node put(Node root, list[&K] keys, &V val) {
	key = head(keys);
	remainder = tail(keys);
	if (isEmpty(remainder)) {
		if (root.next[key]?) {
			root.next[key].keys += [val];
		} else {
			root.next += (key:Node([val], ()));
		}
	} else {
		if (!root.next[key]?) {
			root.next += (key:Node([], ()));
		}
		root.next[key] = put(root.next[key], remainder, val);
	}
	return root;
}