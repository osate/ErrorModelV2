package org.osate.xtext.aadl2.errormodel.util

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.osate.aadl2.Aadl2Package
import org.osate.aadl2.ComponentClassifier
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelLibrary
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelPackage
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelSubclause
import org.osate.xtext.aadl2.ui.MyAadl2Activator

import static extension org.eclipse.emf.ecore.util.EcoreUtil.resolve

class ScopeUtil {
	@Inject
	IGlobalScopeProvider globalScopeProvider
	
	@Inject
	IQualifiedNameConverter qnc;
	
	public val static eInstance = new ScopeUtil
		
	new() {
		val injector = MyAadl2Activator.instance.getInjector(MyAadl2Activator.ORG_OSATE_XTEXT_AADL2_AADL2)
		injector.injectMembers(this)
	}
	
	def public ErrorModelLibrary lookupErrorLibrary(Resource resource) {
		lookupEObject(resource, ErrorModelPackage.Literals.ERROR_MODEL_LIBRARY__EXTENDS, "emv2$ErrorLibrary") as ErrorModelLibrary
	}
	
	def public ErrorModelSubclause lookupErrorModelSubclause(Resource resource,String name) {
		lookupEObject(resource, ErrorModelPackage.Literals.ERROR_MODEL_SUBCLAUSE_REFERENCE_DUMMY__XREF, name) as ErrorModelSubclause
	}
	
	def public ComponentClassifier lookupClassifier(Resource resource, String classifierName) {
		lookupEObject(resource, Aadl2Package.eINSTANCE.portSpecification_Classifier, classifierName) as ComponentClassifier
	}
	
	def public EObject lookupEObject(Resource resource, EReference eref, String name) {
		val qualifiedName = qnc.toQualifiedName(name)
		val scope = globalScopeProvider.getScope(resource, eref, null)
		return scope.getSingleElement(qualifiedName)?.getEObjectOrProxy?.resolve(resource) 
	}
	
}
		