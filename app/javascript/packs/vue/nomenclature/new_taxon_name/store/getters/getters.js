const GetterNames = {
	GetAllRanks: 'getAllRanks',
	GetParent: 'getParent',
	GetRankClass: 'getRankClass',
	GetRankList: 'getRankList',
	GetStatusList: 'getStatusList',
	GetTaxonAuthor: 'getTaxonAuthor',
	GetTaxonName: 'getTaxonName',
	GetTaxonYearPublication: 'getTaxonYearPublication'
};

const GetterFunctions = {
	[GetterNames.GetAllRanks]: require('./getAllRanks'),
	[GetterNames.GetParent]: require('./getParent'),
	[GetterNames.GetRankClass]: require('./getRankClass'),
	[GetterNames.GetRankList]: require('./getRankList'),
	[GetterNames.GetStatusList]: require('./getStatusList'),
	[GetterNames.GetTaxonAuthor]: require('./getTaxonAuthor'),
	[GetterNames.GetTaxonName]: require('./getTaxonName'),
	[GetterNames.GetTaxonYearPublication]: require('./getTaxonYearPublication')
};

module.exports = {
	GetterNames,
	GetterFunctions
}