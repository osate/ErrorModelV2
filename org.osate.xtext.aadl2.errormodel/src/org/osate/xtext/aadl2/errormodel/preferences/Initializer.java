package org.osate.xtext.aadl2.errormodel.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.jface.preference.IPreferenceStore;

public class Initializer extends AbstractPreferenceInitializer {

	/**
	 * Initialize defaults value for preferences of the plug-in
	 */
	@Override
	public void initializeDefaultPreferences() {
		IPreferenceStore store = EMV2Plugin.getDefault().getPreferenceStore();

		store.setDefault(Constants.EMV2_SEPARATE_FILE, Constants.EMV2_SEPARATE_FILE_NO);
	}

}
