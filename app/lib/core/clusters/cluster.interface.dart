typedef IndexList = List<int>;

abstract class Cluster<ClusterTarget> {
  void cluster();
  List<IndexList> get clusteredIndexList;

  List<ClusterTarget> get clusterTarget;
  void updateClusterTarget(List<ClusterTarget> newClusterTarget);
}
