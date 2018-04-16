/*
 * generated by Xtext
 */
package org.osate.xtext.aadl2.errormodel.formatting2;

import com.google.inject.Inject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.osate.aadl2.ModalPropertyValue
import org.osate.xtext.aadl2.errormodel.errorModel.AllExpression
import org.osate.xtext.aadl2.errormodel.errorModel.AndExpression
import org.osate.xtext.aadl2.errormodel.errorModel.CompositeState
import org.osate.xtext.aadl2.errormodel.errorModel.ConditionElement
import org.osate.xtext.aadl2.errormodel.errorModel.ConditionExpression
import org.osate.xtext.aadl2.errormodel.errorModel.EMV2Path
import org.osate.xtext.aadl2.errormodel.errorModel.EMV2PathElement
import org.osate.xtext.aadl2.errormodel.errorModel.EMV2PropertyAssociation
import org.osate.xtext.aadl2.errormodel.errorModel.EMV2Root
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorBehaviorEvent
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorBehaviorState
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorBehaviorStateMachine
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorBehaviorTransition
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorDetection
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorEvent
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorFlow
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelLibrary
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelSubclause
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorPath
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorPropagation
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorSink
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorSource
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorStateToModeMapping
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorType
import org.osate.xtext.aadl2.errormodel.errorModel.FeatureorPPReference
import org.osate.xtext.aadl2.errormodel.errorModel.OrExpression
import org.osate.xtext.aadl2.errormodel.errorModel.OrlessExpression
import org.osate.xtext.aadl2.errormodel.errorModel.OrmoreExpression
import org.osate.xtext.aadl2.errormodel.errorModel.OutgoingPropagationCondition
import org.osate.xtext.aadl2.errormodel.errorModel.PropagationPath
import org.osate.xtext.aadl2.errormodel.errorModel.PropagationPoint
import org.osate.xtext.aadl2.errormodel.errorModel.QualifiedErrorBehaviorState
import org.osate.xtext.aadl2.errormodel.errorModel.QualifiedErrorEventOrPropagation
import org.osate.xtext.aadl2.errormodel.errorModel.QualifiedErrorPropagation
import org.osate.xtext.aadl2.errormodel.errorModel.QualifiedPropagationPoint
import org.osate.xtext.aadl2.errormodel.errorModel.SConditionElement
import org.osate.xtext.aadl2.errormodel.errorModel.TransitionBranch
import org.osate.xtext.aadl2.errormodel.errorModel.TypeMapping
import org.osate.xtext.aadl2.errormodel.errorModel.TypeMappingSet
import org.osate.xtext.aadl2.errormodel.errorModel.TypeSet
import org.osate.xtext.aadl2.errormodel.errorModel.TypeToken
import org.osate.xtext.aadl2.errormodel.errorModel.TypeTransformation
import org.osate.xtext.aadl2.errormodel.errorModel.TypeTransformationSet
import org.osate.xtext.aadl2.errormodel.services.ErrorModelGrammarAccess

class ErrorModelFormatter extends AbstractFormatter2 {
	
	@Inject extension ErrorModelGrammarAccess

	def dispatch void format(EMV2Root emv2root, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(emv2root.getLibrary(), document);
		for (ErrorModelSubclause subclauses : emv2root.getSubclauses()) {
			format(subclauses, document);
		}
	}

	def dispatch void format(ErrorModelSubclause errormodelsubclause, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (ErrorPropagation propagations : errormodelsubclause.getPropagations()) {
			format(propagations, document);
		}
		for (ErrorFlow flows : errormodelsubclause.getFlows()) {
			format(flows, document);
		}
		for (ErrorBehaviorEvent events : errormodelsubclause.getEvents()) {
			format(events, document);
		}
		for (ErrorBehaviorTransition transitions : errormodelsubclause.getTransitions()) {
			format(transitions, document);
		}
		for (OutgoingPropagationCondition outgoingPropagationConditions : errormodelsubclause.getOutgoingPropagationConditions()) {
			format(outgoingPropagationConditions, document);
		}
		for (ErrorDetection errorDetections : errormodelsubclause.getErrorDetections()) {
			format(errorDetections, document);
		}
		for (ErrorStateToModeMapping errorStateToModeMappings : errormodelsubclause.getErrorStateToModeMappings()) {
			format(errorStateToModeMappings, document);
		}
		for (CompositeState states : errormodelsubclause.getStates()) {
			format(states, document);
		}
		for (ErrorSource connectionErrorSources : errormodelsubclause.getConnectionErrorSources()) {
			format(connectionErrorSources, document);
		}
		for (PropagationPoint points : errormodelsubclause.getPoints()) {
			format(points, document);
		}
		for (PropagationPath paths : errormodelsubclause.getPaths()) {
			format(paths, document);
		}
		for (EMV2PropertyAssociation properties : errormodelsubclause.getProperties()) {
			format(properties, document);
		}
	}

	def dispatch void format(ErrorModelLibrary errormodellibrary, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (ErrorType types : errormodellibrary.getTypes()) {
			format(types, document);
		}
		for (TypeSet typesets : errormodellibrary.getTypesets()) {
			format(typesets, document);
		}
		for (EMV2PropertyAssociation properties : errormodellibrary.getProperties()) {
			format(properties, document);
		}
		for (ErrorBehaviorStateMachine behaviors : errormodellibrary.getBehaviors()) {
			format(behaviors, document);
		}
		for (TypeMappingSet mappings : errormodellibrary.getMappings()) {
			format(mappings, document);
		}
		for (TypeTransformationSet transformations : errormodellibrary.getTransformations()) {
			format(transformations, document);
		}
	}

	def dispatch void format(EMV2PropertyAssociation emv2propertyassociation, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (ModalPropertyValue ownedValues : emv2propertyassociation.getOwnedValues()) {
			format(ownedValues, document);
		}
		for (EMV2Path emv2Path : emv2propertyassociation.getEmv2Path()) {
			format(emv2Path, document);
		}
	}

	def dispatch void format(EMV2Path emv2path, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(emv2path.getContainmentPath(), document);
		format(emv2path.getEmv2Target(), document);
	}

	def dispatch void format(EMV2PathElement emv2pathelement, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(emv2pathelement.getPath(), document);
	}

	def dispatch void format(TypeSet typeset, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (TypeToken typeTokens : typeset.getTypeTokens()) {
			format(typeTokens, document);
		}
	}

	def dispatch void format(TypeTransformationSet typetransformationset, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (TypeTransformation transformation : typetransformationset.getTransformation()) {
			format(transformation, document);
		}
	}

	def dispatch void format(TypeTransformation typetransformation, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(typetransformation.getSource(), document);
		format(typetransformation.getContributor(), document);
		format(typetransformation.getTarget(), document);
	}

	def dispatch void format(TypeMappingSet typemappingset, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (TypeMapping mapping : typemappingset.getMapping()) {
			format(mapping, document);
		}
	}

	def dispatch void format(TypeMapping typemapping, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(typemapping.getSource(), document);
		format(typemapping.getTarget(), document);
	}

	def dispatch void format(ErrorPropagation errorpropagation, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(errorpropagation.getFeatureorPPRef(), document);
		format(errorpropagation.getTypeSet(), document);
	}

	def dispatch void format(FeatureorPPReference featureorppreference, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(featureorppreference.getNext(), document);
	}

	def dispatch void format(ErrorSource errorsource, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(errorsource.getTypeTokenConstraint(), document);
		format(errorsource.getFailureModeType(), document);
	}

	def dispatch void format(ErrorSink errorsink, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(errorsink.getTypeTokenConstraint(), document);
	}

	def dispatch void format(ErrorPath errorpath, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(errorpath.getTypeTokenConstraint(), document);
		format(errorpath.getTargetToken(), document);
	}

	def dispatch void format(PropagationPath propagationpath, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(propagationpath.getSource(), document);
		format(propagationpath.getTarget(), document);
	}

	def dispatch void format(QualifiedPropagationPoint qualifiedpropagationpoint, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(qualifiedpropagationpoint.getSubcomponent(), document);
		format(qualifiedpropagationpoint.getNext(), document);
	}

	def dispatch void format(ErrorBehaviorStateMachine errorbehaviorstatemachine, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (ErrorBehaviorEvent events : errorbehaviorstatemachine.getEvents()) {
			format(events, document);
		}
		for (ErrorBehaviorState states : errorbehaviorstatemachine.getStates()) {
			format(states, document);
		}
		for (ErrorBehaviorTransition transitions : errorbehaviorstatemachine.getTransitions()) {
			format(transitions, document);
		}
		for (EMV2PropertyAssociation properties : errorbehaviorstatemachine.getProperties()) {
			format(properties, document);
		}
	}

	def dispatch void format(ErrorEvent errorevent, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(errorevent.getTypeSet(), document);
	}

	def dispatch void format(ErrorBehaviorState errorbehaviorstate, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(errorbehaviorstate.getTypeSet(), document);
	}

	def dispatch void format(ErrorBehaviorTransition errorbehaviortransition, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(errorbehaviortransition.getTypeTokenConstraint(), document);
		format(errorbehaviortransition.getCondition(), document);
		format(errorbehaviortransition.getTargetToken(), document);
		for (TransitionBranch destinationBranches : errorbehaviortransition.getDestinationBranches()) {
			format(destinationBranches, document);
		}
	}

	def dispatch void format(TransitionBranch transitionbranch, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(transitionbranch.getTargetToken(), document);
		format(transitionbranch.getValue(), document);
	}

	def dispatch void format(OrExpression orexpression, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (ConditionExpression operands : orexpression.getOperands()) {
			format(operands, document);
		}
	}

	def dispatch void format(AndExpression andexpression, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (ConditionExpression operands : andexpression.getOperands()) {
			format(operands, document);
		}
	}

	def dispatch void format(AllExpression allexpression, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (ConditionElement operands : allexpression.getOperands()) {
			format(operands, document);
		}
	}

	def dispatch void format(OrmoreExpression ormoreexpression, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (ConditionExpression operands : ormoreexpression.getOperands()) {
			format(operands, document);
		}
	}

	def dispatch void format(OrlessExpression orlessexpression, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (ConditionExpression operands : orlessexpression.getOperands()) {
			format(operands, document);
		}
	}

	def dispatch void format(ConditionElement conditionelement, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(conditionelement.getQualifiedErrorPropagationReference(), document);
		format(conditionelement.getConstraint(), document);
	}

	def dispatch void format(QualifiedErrorEventOrPropagation qualifiederroreventorpropagation, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(qualifiederroreventorpropagation.getEmv2Target(), document);
	}

	def dispatch void format(OutgoingPropagationCondition outgoingpropagationcondition, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(outgoingpropagationcondition.getTypeTokenConstraint(), document);
		format(outgoingpropagationcondition.getCondition(), document);
		format(outgoingpropagationcondition.getTypeToken(), document);
	}

	def dispatch void format(ErrorDetection errordetection, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(errordetection.getTypeTokenConstraint(), document);
		format(errordetection.getCondition(), document);
		format(errordetection.getErrorCode(), document);
	}

	def dispatch void format(ErrorStateToModeMapping errorstatetomodemapping, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(errorstatetomodemapping.getTypeToken(), document);
	}

	def dispatch void format(CompositeState compositestate, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(compositestate.getCondition(), document);
		format(compositestate.getTypedToken(), document);
	}

	def dispatch void format(QualifiedErrorPropagation qualifiederrorpropagation, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(qualifiederrorpropagation.getEmv2Target(), document);
	}

	def dispatch void format(SConditionElement sconditionelement, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(sconditionelement.getQualifiedState(), document);
		format(sconditionelement.getConstraint(), document);
		format(sconditionelement.getQualifiedErrorPropagationReference(), document);
	}

	def dispatch void format(QualifiedErrorBehaviorState qualifiederrorbehaviorstate, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		format(qualifiederrorbehaviorstate.getSubcomponent(), document);
		format(qualifiederrorbehaviorstate.getNext(), document);
	}
}
