import { MutationNames } from '../mutations/mutations';
import { CreateTypeMaterial } from '../../request/resources';

export default function({ commit, state }, data) {
	commit(MutationNames.SetSaving, true);
	CreateTypeMaterial(data).then(response => {
		TW.workbench.alert.create('Type specimen was successfully created.', 'notice');
		commit(MutationNames.AddTypeMaterial, response);
		commit(MutationNames.SetTypeMaterial, response);
		commit(MutationNames.SetSaving, false);
	})
};