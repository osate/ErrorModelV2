package org.osate.xtext.aadl2.errormodel.preferences;

import org.eclipse.jface.preference.IPreferenceStore;

public class Values {
	public static boolean doEmbeddedEMV2Only() {
		IPreferenceStore store = EMV2Plugin.getDefault().getPreferenceStore();
		String policy = store.getString(Constants.EMV2_SEPARATE_FILE);
		return policy.equalsIgnoreCase(Constants.EMV2_SEPARATE_FILE_NO);
	}
}
