import ActionNames from './actionNames'

import importRow from './importRow'
import loadDataset from './loadDataset'
import loadDatasetRecords from './loadDataSetRecords'
import updateRow from './updateRow'
import processImport from './processImport'

const ActionFunctions = {
  [ActionNames.ImportRow]: importRow,
  [ActionNames.LoadDataset]: loadDataset,
  [ActionNames.LoadDatasetRecords]: loadDatasetRecords,
  [ActionNames.UpdateRow]: updateRow,
  [ActionNames.ProcessImport]: processImport
}

export {
  ActionFunctions,
  ActionNames
}
