community-evolution-analysis
============================

##A framework for the analysis of social interaction networks (e.g. induced by Twitter mentions) in time.##
We make available a Twitter interaction network collector and a set of Matlab scripts that enable the analysis of social interaction networks with the goal of uncovering evolving communities. More specifically, the interaction network collector forms a network between Twitter users based on the mentions in the set of monitored tweets (using the Streaming API). The network of interactions is adaptively partitioned into snapshot graphs based on the frequency of interactions (more details in [1]). Then, each graph snapshot is partitioned into communities using the Louvain method [2]. Finally, evolving communities are extracted by matching the communities of the current graph snapshot to communities of previous snapshots.

The master  branch of this repository contains ongoing matlab and python files which form the current stable version of the framework. The PCI13 branch contains all the code and data needed to replicate the experiments performed in [1].

1. K. Konstandinidis, S. Papadopoulos, Y. Kompatsiaris. "Community Structure, Interaction and Evolution Analysis of Online Social Networks around Real-World Social Phenomena". In Proceedings of PCI 2013, Thessaloniki, Greece (to be presented on September).
2. V. Blondel, J.-L. Guillaume, R. Lambiotte, E. Lefebvre. "Fast unfolding of communities in large networks". In Journal of Statistical Mechanics: Theory and Experiment (10), P10008, 2008
