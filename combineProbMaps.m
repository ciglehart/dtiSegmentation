clear all;

map1 = '~/Documents/Research/comparisonStudy/data/probMaps/stProbMapL.mat';
map2 = '~/Documents/Research/comparisonStudy/data/probMaps/stProbMapR.mat';
outMap = '~/Documents/Research/comparisonStudy/data/probMaps/stProbMapCombined.mat';

load(map1);
map1 = probMap;
load(map2);
map2 = probMap;

probMap.indicator = map1.indicator + map2.indicator;
probMap.p = map1.p + map2.p;
probMap.c = map1.c + map2.c;
probMap.maxMap = map1.maxMap + map2.maxMap;

save(outMap,'probMap');