// we create an extension on Stream  called Filter
extension Filter<T> on Stream<List<T>> {
  // we create a function that return a stream<List<T>>.
  // the filter method accepts a calback func where that return a bool. 
  // we iterate through the items of type T and only retun items that satisfy the where func. 
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
