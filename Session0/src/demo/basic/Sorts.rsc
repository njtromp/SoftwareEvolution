module demo::basic::Sorts

import List;
import IO;

public list[int] bubbleSort(list[int] numbers) {
	if (size(numbers) > 0) {
		for (int i <- [0 .. size(numbers)-1]) {
			if (numbers[i] > numbers[i+1]) {
				<numbers[i], numbers[i+1]> = <numbers[i+1], numbers[i]>;
				return bubbleSort(numbers);
			}
		}
	}
	return numbers;
}

public list[int] mergeSort(list[int] numbers) {
	switch(numbers) {
		case []  : return [];
		case [x] : return [x];
		default  : {
			half = size(numbers) / 2;
			left = mergeSort(slice(numbers, 0, half));
			right = mergeSort(slice(numbers, half, size(numbers) - half));
			return mergeSorted(left, right);
		}
	}
}

private list[int] mergeSorted(list[int] left, list[int] right) {
	switch (<left, right>) {
		case <[], _> : return right;
		case <_, []> : return left;
		case <[l, *ltail], [r, *rtail]> : {
			if (l <= r) {
				return l + mergeSorted(tail(left), right);
			} else {
				return r + mergeSorted(left, tail(right));
			}	
		}
	}
}

public list[int] MergeSort([]) { return []; }
public list[int] MergeSort([int n]) { return [n]; }
public default list[int] MergeSort(list[int] numbers) {
	half = size(numbers) / 2;
	left = MergeSort(slice(numbers, 0, half));
	right = MergeSort(slice(numbers, half, size(numbers) - half));
	return MergeSorted(left, right);
}

private list[int] MergeSorted([], list[int] right) { return right; }
private list[int] MergeSorted(list[int] left, []) { return left; }
private default list[int] MergeSorted([int l, *int ltail], [int r, *int rtail]) {
	if (l <= r) {
		return l + MergeSorted(ltail, r + rtail);
	} else {
		return r + MergeSorted(l + ltail, rtail);
	}	
}
