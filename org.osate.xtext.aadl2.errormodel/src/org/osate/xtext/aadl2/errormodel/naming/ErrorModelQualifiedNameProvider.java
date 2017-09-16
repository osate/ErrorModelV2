package org.osate.xtext.aadl2.errormodel.naming;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider;
import org.eclipse.xtext.naming.QualifiedName;
import org.osate.aadl2.AadlPackage;
import org.osate.aadl2.NamedElement;
import org.osate.xtext.aadl2.errormodel.errorModel.EMV2Package;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorBehaviorStateMachine;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelLibrary;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelSubclause;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorType;
import org.osate.xtext.aadl2.errormodel.errorModel.TypeMappingSet;
import org.osate.xtext.aadl2.errormodel.errorModel.TypeSet;
import org.osate.xtext.aadl2.errormodel.errorModel.TypeTransformationSet;

public class ErrorModelQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {

	// Enable to limit indexing to global items
	// Duplicates checking only applies to global items
	@Override
	public QualifiedName getFullyQualifiedName(final EObject obj) {
		if (obj instanceof ErrorBehaviorStateMachine || obj instanceof TypeMappingSet
				|| obj instanceof ErrorModelLibrary || obj instanceof ErrorModelSubclause || obj instanceof ErrorType
				|| obj instanceof TypeSet || obj instanceof TypeTransformationSet) {
			/*
			 * It is important that we return null if obj is not in an
			 * AadlPackage or in a EMV2Root. This happens when serializing an
			 * aadl file with an error model annex. See EMV2AnnexUnparser. If
			 * this check is not here, then a ClassCastException occurs during
			 * serialization.
			 */
			NamedElement namedElement = (NamedElement) obj;
			NamedElement root = namedElement.getElementRoot();
			if (namedElement.getName() == null
					|| !(root instanceof AadlPackage || root instanceof EMV2Package
							|| root instanceof ErrorModelLibrary)
					|| (obj instanceof ErrorModelSubclause && !(root instanceof EMV2Package))) {
				return null;
			}
			return getConverter().toQualifiedName(getTheName(namedElement));
		}
		if (obj instanceof AadlPackage || obj instanceof EMV2Package) {
			return getConverter().toQualifiedName(((NamedElement) obj).getName());
		}
		return null;
	}

	protected String getTheName(NamedElement namedElement) {
		NamedElement root = namedElement.getElementRoot();
		if (root instanceof ErrorModelLibrary || root instanceof EMV2Package) {
			if (namedElement instanceof ErrorModelLibrary) {
				return namedElement.getName();
			}
				return root.getName() + "::" + namedElement.getName();
		}
		if (namedElement instanceof ErrorModelLibrary) {
			return "emv2$" + root.getName();
		}
		return "emv2$" + root.getName() + "::" + namedElement.getName();
	}
}