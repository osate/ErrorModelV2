package org.osate.xtext.aadl2.errormodel.scoping

import com.google.inject.Inject
import java.util.List
import java.util.Optional
import java.util.stream.Collectors
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.osate.aadl2.BasicPropertyAssociation
import org.osate.aadl2.Classifier
import org.osate.aadl2.ComponentClassifier
import org.osate.aadl2.ComponentImplementation
import org.osate.aadl2.ContainmentPathElement
import org.osate.aadl2.DirectionType
import org.osate.aadl2.Element
import org.osate.aadl2.EnumerationType
import org.osate.aadl2.FeatureGroup
import org.osate.aadl2.PropertyType
import org.osate.aadl2.RecordType
import org.osate.aadl2.Subcomponent
import org.osate.aadl2.TriggerPort
import org.osate.xtext.aadl2.errormodel.errorModel.ConditionExpression
import org.osate.xtext.aadl2.errormodel.errorModel.ConnectionErrorSource
import org.osate.xtext.aadl2.errormodel.errorModel.EMV2Path
import org.osate.xtext.aadl2.errormodel.errorModel.EMV2PathElement
import org.osate.xtext.aadl2.errormodel.errorModel.EMV2PropertyAssociation
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorBehaviorState
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorBehaviorStateMachine
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorBehaviorTransition
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorDetection
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorEvent
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelLibrary
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelSubclause
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorPropagation
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorSink
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorSource
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorType
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorTypes
import org.osate.xtext.aadl2.errormodel.errorModel.FeatureorPPReference
import org.osate.xtext.aadl2.errormodel.errorModel.OutgoingPropagationCondition
import org.osate.xtext.aadl2.errormodel.errorModel.QualifiedErrorBehaviorState
import org.osate.xtext.aadl2.errormodel.errorModel.QualifiedErrorEventOrPropagation
import org.osate.xtext.aadl2.errormodel.errorModel.QualifiedErrorPropagation
import org.osate.xtext.aadl2.errormodel.errorModel.QualifiedPropagationPoint
import org.osate.xtext.aadl2.errormodel.errorModel.TypeMappingSet
import org.osate.xtext.aadl2.errormodel.errorModel.TypeTransformationSet
import org.osate.xtext.aadl2.errormodel.serializer.ErrorModelCrossReferenceSerializer
import org.osate.xtext.aadl2.errormodel.util.EMV2Util
import org.osate.xtext.aadl2.properties.scoping.PropertiesScopeProvider

import static extension org.eclipse.xtext.EcoreUtil2.getContainerOfType
import static extension org.osate.aadl2.modelsupport.util.AadlUtil.getBasePropertyType
import static extension org.osate.xtext.aadl2.errormodel.util.EMV2Util.*
import static extension org.osate.xtext.aadl2.errormodel.util.ErrorModelUtil.getAllErrorTypes
import static extension org.osate.xtext.aadl2.errormodel.util.ErrorModelUtil.getAllTypesets

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping
 * on how and when to use it 
 * 
 */
class ErrorModelScopeProvider extends PropertiesScopeProvider {
	@Inject
	IQualifiedNameConverter qualifiedNameConverter
	
	override scope_NamedValue_namedValue(Element context, EReference reference) {
		var scope = delegateGetScope(context, reference)
		var PropertyType propertyType = null;
		//Inner value of a record value.
		propertyType = context.getContainerOfType(BasicPropertyAssociation)?.property?.propertyType
		if (propertyType == null) {
			//Value of an association.
			propertyType = context.getContainerOfType(EMV2PropertyAssociation)?.property?.propertyType
		}
		propertyType = propertyType.basePropertyType
		if (propertyType instanceof EnumerationType) {
			scope = propertyType.ownedLiterals.scopeFor(scope)
		}
		scope
	}
	
	override scope_BasicPropertyAssociation_property(Element context, EReference reference) {
		val parentBpa = context.eContainer.getContainerOfType(BasicPropertyAssociation)
		val property = if (parentBpa != null) {
			parentBpa.property
		} else {
			context.getContainerOfType(EMV2PropertyAssociation).property
		}
		switch baseType : property.propertyType?.basePropertyType {
			RecordType: baseType.ownedFields.scopeFor
			default: IScope.NULLSCOPE
		}
	}
	
	override scope_ModalElement_inMode(Element context, EReference reference) {
		IScope.NULLSCOPE
	}
	
	def scope_NumberValue_unit(EObject context, EReference reference) {
		val parentBpa = context.getContainerOfType(BasicPropertyAssociation)
		val property = if (parentBpa != null) {
			parentBpa.property
		} else {
			context.getContainerOfType(EMV2PropertyAssociation).property
		}
		createUnitLiteralsScopeFromPropertyType(property.propertyType)
	}
	
	//TODO Implement test case after talking with Peter
	def scope_ContainmentPathElement_namedElement(ContainmentPathElement context, EReference reference) {
		switch parent : context.eContainer {
			EMV2Path: parent.getContainerOfType(ComponentImplementation)?.allSubcomponents?.filterRefined?.scopeFor ?: IScope.NULLSCOPE
			//TODO: This could change after talking with Peter about reference values
			ContainmentPathElement: switch previous : parent.namedElement {
				Subcomponent case !previous.eIsProxy: switch classifier : previous.allClassifier {
					ComponentImplementation: classifier.allSubcomponents.filterRefined.scopeFor
					default: IScope.NULLSCOPE
				}
				default: IScope.NULLSCOPE
			}
			//TODO: Ask Peter about reference values
			default: IScope.NULLSCOPE
		}
	}
	
	def scope_ErrorModelLibrary(EObject context, EReference reference) {
		scopeWithoutEMV2Prefix(context, reference)
	}

	def scope_TypeMappingSet(EObject context, EReference reference) {
		scopeWithoutEMV2Prefix(context, reference)
	}

	def scope_ErrorModelSubclause_useBehavior(EObject context, EReference reference) {
		scopeWithoutEMV2Prefix(context, reference)
	}

	def scope_TypeTransformationSet(EObject context, EReference reference) {
		scopeWithoutEMV2Prefix(context, reference)
	}
	
	/*
	 * This is a very complicated scoping rule. First of all, EMV2PathElement can be chained (e.g. "name1.name2.name3")
	 * and the contents of the scope are different for the first element than for subsequent elements. More importantly,
	 * the contents of the scope depend on which grammar rules were used to create the EMV2PathElement. In other words,
	 * the scope for an EMV2PathElement in the condition of an ErrorDetection is different from the scope for an
	 * EMV2PathElement in the "applies to" of an EMV2PropertyAssociation in an ErrorBehaviorStateMachine. To better
	 * understand this scoping rule, please use Graphviz on the following diagram:
	 * 
		digraph EMV2PathElement {
			ErrorModelLibrary [fontcolor=blue, fontsize=20]
			ErrorModelSubclause [fontcolor=blue, fontsize=20]
			EMV2PathElementOrKind [fontcolor=red, fontsize=20]
			EMV2PathElement [fontcolor=red, fontsize=20]
			EMV2ErrorPropagationPath [fontcolor=red, fontsize=20]
			BasicEMV2Path -> EMV2PathElementOrKind
			EMV2Path -> EMV2PathElementOrKind
			EMV2PathElementOrKind -> EMV2PathElement
			EMV2PathElement -> EMV2PathElement
			EMV2ErrorPropagationPath -> EMV2ErrorPropagationPath
			QualifiedErrorEventOrPropagation -> EMV2ErrorPropagationPath
			QualifiedErrorPropagation -> EMV2ErrorPropagationPath
			BasicEMV2PropertyAssociation -> BasicEMV2Path
			EMV2PropertyAssociation -> EMV2Path
			ErrorModelSubclause -> EMV2PropertyAssociation
			ErrorBehaviorStateMachine -> BasicEMV2PropertyAssociation
			ErrorModelLibrary -> BasicEMV2PropertyAssociation
			ErrorModelLibrary -> ErrorBehaviorStateMachine
			ConditionElement -> QualifiedErrorEventOrPropagation
			AllExpression -> ConditionElement
			ConditionTerm -> ConditionElement
			OrlessExpression -> ConditionElement
			ConditionTerm -> AllExpression
			ConditionTerm -> OrlessExpression
			AndExpression -> ConditionTerm
			ConditionExpression -> AndExpression
			ConditionTerm -> ConditionExpression
			ErrorBehaviorTransition -> ConditionExpression
			ErrorDetection -> ConditionExpression
			OrmoreExpression -> ConditionExpression
			OutgoingPropagationCondition -> ConditionExpression
			ErrorBehaviorStateMachine -> ErrorBehaviorTransition
			ErrorModelSubclause -> ErrorBehaviorTransition
			ErrorModelSubclause -> ErrorDetection
			ConditionTerm -> OrmoreExpression
			ErrorModelSubclause -> OutgoingPropagationCondition
			SConditionElement -> QualifiedErrorPropagation
			SAllExpression -> SConditionElement
			SConditionTerm -> SConditionElement
			SOrlessExpression -> SConditionElement
			SOrmoreExpression -> SConditionElement
			SConditionTerm -> SAllExpression
			SConditionTerm -> SOrlessExpression
			SConditionTerm -> SOrmoreExpression
			SAndExpression -> SConditionTerm
			SConditionExpression -> SAndExpression
			CompositeState -> SConditionExpression
			SConditionTerm -> SConditionExpression
			ErrorModelSubclause -> CompositeState
		}
	 * 
	 * EMV2PathElement objects are created in the grammar rules EMV2PathElementOrKind, EMV2PathElement, and
	 * EMV2ErrorPropagationPath. The graph shows all of the possible ways to get to one of these grammar rules from
	 * the rules ErrorModelLibrary and ErrorModelSubclause. Throughout this method, there are comments which state which
	 * grammar path in the graph is being tested for. 
	 * 
	 * Scope elements for grammar path: ErrorModelLibrary -> ErrorBehaviorStateMachine -> ErrorBehaviorTransition ->
	 * 			ConditionExpression -> ... -> QualifiedErrorEventOrPropagation -> EMV2ErrorPropagationPath
	 * 		ErrorBehaviorEvent
	 * 
	 * Scope elements for grammar path: ErrorModelSubclause -> ErrorBehaviorTransition -> ConditionExpression -> ... ->
	 * 			QualifiedErrorEventOrPropagation -> EMV2ErrorPropagationPath
	 * 		ErrorBehaviorEvent |
	 * 		(Subcomponent '.')* (FeatureGroup '.')* ErrorPropagation
	 * 
	 * Scope elements for grammar path: ErrorModelSubclause -> OutgoingPropagationCondition -> ConditionExpression ->
	 * 			... -> QualifiedErrorEventOrPropagation -> EMV2ErrorPropagationPath
	 * 		ErrorBehaviorEvent |
	 * 		(Subcomponent '.')* (FeatureGroup '.')* ErrorPropagation
	 * 
	 * Scope elements for grammar path: ErrorModelSubclause -> ErrorDetection -> ConditionExpression -> ... ->
	 * 			QualifiedErrorEventOrPropagation -> EMV2ErrorPropagationPath
	 * 		ErrorBehaviorEvent |
	 * 		(Subcomponent '.')* (FeatureGroup '.')* ErrorPropagation
	 * 
	 * Scope elements for grammar path: ErrorModelSubclause -> CompositeState -> SConditionExpression -> ... ->
	 * 			QualifiedErrorPropagation -> EMV2ErrorPropagationPath
	 * 		(FeatureGroup '.')* ErrorPropagation
	 * 
	 * Scope elements for grammar path: ErrorModelLibrary -> BasicEMV2PropertyAssociation -> BasicEMV2Path ->
	 * 			EMV2PathElementOrKind
	 * 		ErrorTypes
	 * 
	 * Scope elements for grammar path: ErrorModelLibrary -> ErrorBehaviorStateMachine ->
	 * 			BasicEMV2PropartyAssociation -> BasicEMV2Path -> EMV2PathElementOrKind
	 * 		ErrorBehaviorEvent |
	 * 		ErrorBehaviorState |
	 * 		ErrorBehaviorTransition
	 * 
	 * Scope elements for grammar path: ErrorModelSubclause -> EMV2PropertyAssociation -> EMV2Path ->
	 * 			EMV2PathElementOrKind
	 * 		(FeatureGroup '.')* ErrorPropagation ('.' ErrorType)? |
	 * 		ErrorBehaviorEvent ('.' ErrorType)? |
	 * 		ErrorBehaviorTransition |
	 * 		OutgoingPropagationConditoin |
	 * 		ErrorDetection |
	 * 		CompositeState |
	 * 		ConnectionErrorSource ('.' ErrorType)? |
	 * 		PropagationPath |
	 * 		ErrorSource ('.' ErrorType)? |
	 * 		ErrorSink ('.' ErrorType)? |
	 * 		ErrorPath |
	 * 		ErrorBehaviorState ('.' ErrorType)?
	 */
	def scope_EMV2PathElement_namedElement(EMV2PathElement context, EReference reference) {
		switch parent : context.eContainer {
			QualifiedErrorEventOrPropagation: {
				val topConditionExpression = parent.allContainers.filter(ConditionExpression).last
				switch parentOfCondition : topConditionExpression.eContainer {
					ErrorBehaviorTransition: switch parentOfTransition : parentOfCondition.eContainer {
						/*
						 * First element in chain.
						 * Grammar path: ErrorModelLibrary -> ErrorBehaviorStateMachine -> ErrorBehaviorTransition ->
						 * 		ConditionExpression -> ... -> QualifiedErrorEventOrPropagation -> EMV2ErrorPropagationPath
						 */
						ErrorBehaviorStateMachine: parentOfTransition.events.scopeFor
						/*
						 * First element in chain.
						 * Grammar path: ErrorModelSubclause -> ErrorBehaviorTransition -> ConditionExpression ->
						 * 		... -> QualifiedErrorEventOrPropagation -> EMV2ErrorPropagationPath
						 */
						ErrorModelSubclause: {
							val events = parentOfTransition.allContainingClassifierEMV2Subclauses.map[
								events + (useBehavior?.events ?: emptyList)
							].flatten
							val featureGroups = parentOfTransition.getContainerOfType(Classifier).allFeatures.filter(FeatureGroup)
							val List<Subcomponent> subcomponents = parentOfTransition.getContainerOfType(ComponentImplementation)?.allSubcomponents ?: emptyList
							val propagations = parentOfTransition.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter[
								featureorPPRef != null && featureorPPRef.next == null && featureorPPRef.featureorPP.name != null
							]
							val propagationsScope = new SimpleScope(propagations.map[EObjectDescription.create(featureorPPRef.featureorPP.name, it)], true)
							(events + featureGroups + subcomponents).scopeFor(propagationsScope)
						}
					}
					/*
					 * First element in chain.
					 * Grammar path: ErrorModelSubclause -> OutgoingPropagationCondition -> ConditionExpression ->
					 * 		... -> QualifiedErrorEventOrPropagation -> EMV2ErrorPropagationPath
					 */
					OutgoingPropagationCondition: {
						val events = parentOfCondition.allContainingClassifierEMV2Subclauses.map[
							events + (useBehavior?.events ?: emptyList)
						].flatten
						val featureGroups = parentOfCondition.getContainerOfType(Classifier).allFeatures.filter(FeatureGroup)
						val List<Subcomponent> subcomponents = parentOfCondition.getContainerOfType(ComponentImplementation)?.allSubcomponents ?: emptyList
						val propagations = parentOfCondition.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter[
							featureorPPRef != null && featureorPPRef.next == null && featureorPPRef.featureorPP.name != null
						]
						val propagationsScope = new SimpleScope(propagations.map[EObjectDescription.create(featureorPPRef.featureorPP.name, it)], true)
						(events + featureGroups + subcomponents).scopeFor(propagationsScope)
					}
					/*
					 * First element in chain.
					 * Grammar path: ErrorModelSubclause -> ErrorDetection -> ConditionExpression -> ... ->
					 * 		QualifiedErrorEventOrPropagation -> EMV2ErrorPropagationPath
					 */
					ErrorDetection: {
						val events = parentOfCondition.allContainingClassifierEMV2Subclauses.map[
							events + (useBehavior?.events ?: emptyList)
						].flatten
						val featureGroups = parentOfCondition.getContainerOfType(Classifier).allFeatures.filter(FeatureGroup)
						val List<Subcomponent> subcomponents = parentOfCondition.getContainerOfType(ComponentImplementation)?.allSubcomponents ?: emptyList
						val propagations = parentOfCondition.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter[
							featureorPPRef != null && featureorPPRef.next == null && featureorPPRef.featureorPP.name != null
						]
						val propagationsScope = new SimpleScope(propagations.map[EObjectDescription.create(featureorPPRef.featureorPP.name, it)], true)
						(events + featureGroups + subcomponents).scopeFor(propagationsScope)
					}
				}
			}
			/*
			 * First element in chain.
			 * Grammar path: ErrorModelSubclause -> CompositeState -> SConditionExpression -> ... ->
			 * 		QualifiedErrorPropagation -> EMV2ErrorPropagationPath
			 */
			QualifiedErrorPropagation: {
				val featureGroups = parent.getContainerOfType(Classifier).allFeatures.filter(FeatureGroup)
				val propagations = parent.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter[
					featureorPPRef != null && featureorPPRef.next == null && featureorPPRef.featureorPP.name != null
				]
				val propagationsScope = new SimpleScope(propagations.map[EObjectDescription.create(featureorPPRef.featureorPP.name, it)], true)
				featureGroups.scopeFor(propagationsScope)
			}
			EMV2Path: {
				val parentOfAssociation = parent.eContainer.eContainer
				switch parentOfAssociation {
					/*
					 * First element in chain.
					 * Grammar path: ErrorModelLibrary -> BasicEMV2PropertyAssociation -> BasicEMV2Path ->
					 * 		EMV2PathElementOrKind
					 */
					ErrorModelLibrary: (parentOfAssociation.allErrorTypes + parentOfAssociation.allTypesets).scopeFor
					/*
					 * First element in chain.
					 * Grammar path: ErrorModelLibrary -> ErrorBehaviorStateMachine -> BasicEMV2PropartyAssociation ->
					 * 		BasicEMV2Path -> EMV2PathElementOrKind
					 */
					ErrorBehaviorStateMachine: (parentOfAssociation.events + parentOfAssociation.states + parentOfAssociation.transitions).scopeFor
					/*
					 * First element in chain.
					 * Grammar path: ErrorModelSubclause -> EMV2PropertyAssociation -> EMV2Path -> EMV2PathElementOrKind
					 * No containment path in applies to. Example: "property => value applies to name1"
					 */
					ErrorModelSubclause case parent.containmentPath == null: {
						val featureGroups = parentOfAssociation.getContainerOfType(Classifier).allFeatures.filter(FeatureGroup)
						val subclauseElements = parentOfAssociation.allContainingClassifierEMV2Subclauses.map[
							val behaviorElements = if (useBehavior != null) {
								useBehavior.events + useBehavior.states + useBehavior.transitions
							} else {
								emptyList
							}
							val localElements = flows + events + transitions + outgoingPropagationConditions +
								errorDetections + states + connectionErrorSources + paths
							behaviorElements + localElements
						].flatten
						val propagations = parentOfAssociation.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter[
							featureorPPRef != null && featureorPPRef.next == null && featureorPPRef.featureorPP.name != null
						]
						val propagationsScope = new SimpleScope(propagations.map[EObjectDescription.create(featureorPPRef.featureorPP.name, it)], true)
						(featureGroups + subclauseElements).scopeFor(propagationsScope)
					}
					/*
					 * First element in chain.
					 * Grammar path: ErrorModelSubclause -> EMV2PropertyAssociation -> EMV2Path -> EMV2PathElementOrKind
					 * Containment path in applies to. Example: "property => value applies to ^name1.name2@.name3"
					 */
					ErrorModelSubclause: {
						var lastContainmentPath = parent.containmentPath
						while (lastContainmentPath.path != null) {
							lastContainmentPath = lastContainmentPath.path
						}
						val lastSubcomponent = lastContainmentPath.namedElement
						if (lastSubcomponent instanceof Subcomponent) {
							val classifier = lastSubcomponent.allClassifier
							if (classifier != null) {
								val featureGroups = classifier.allFeatures.filter(FeatureGroup)
								val subclauseElements = classifier.allContainingClassifierEMV2Subclauses.map[
									val behaviorElements = if (useBehavior != null) {
										useBehavior.events + useBehavior.states + useBehavior.transitions
									} else {
										emptyList
									}
									val localElements = flows + events + transitions + outgoingPropagationConditions +
										errorDetections + states + connectionErrorSources + paths
									behaviorElements + localElements
								].flatten
								val propagations = classifier.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter[
									featureorPPRef != null && featureorPPRef.next == null && featureorPPRef.featureorPP.name != null
								]
								val propagationsScope = new SimpleScope(propagations.map[EObjectDescription.create(featureorPPRef.featureorPP.name, it)], true)
								(featureGroups + subclauseElements).scopeFor(propagationsScope)
							} else {
								IScope.NULLSCOPE
							}
						} else {
							IScope.NULLSCOPE
						}
					}
				}
			}
			//Subsequent elements in chain
			EMV2PathElement case !parent.namedElement.eIsProxy: {
				switch previous : parent.namedElement {
					ErrorSource: previous.typeTokenConstraint?.typeTokens?.filter[type.size == 1]?.map[type.head]?.filter(ErrorType)?.scopeFor ?: IScope.NULLSCOPE
					ErrorSink: previous.typeTokenConstraint?.typeTokens?.filter[type.size == 1]?.map[type.head]?.filter(ErrorType)?.scopeFor ?: IScope.NULLSCOPE
					ConnectionErrorSource: previous.typeTokenConstraint?.typeTokens?.filter[type.size == 1]?.map[type.head]?.filter(ErrorType)?.scopeFor ?: IScope.NULLSCOPE
					ErrorBehaviorState: previous.typeSet?.typeTokens?.filter[type.size == 1]?.map[type.head]?.filter(ErrorType)?.scopeFor ?: IScope.NULLSCOPE
					/*
					 * Grammar path: ErrorModelSubclause -> EMV2PropertyAssociation -> EMV2Path ->
					 * 		EMV2PathElementOrKind -> EMV2PathElement
					 */
					ErrorEvent case
						parent.eContainer instanceof EMV2Path &&
						parent.eContainer.eContainer.eContainer instanceof ErrorModelSubclause:
							previous.typeSet?.typeTokens?.filter[type.size == 1]?.map[type.head]?.filter(ErrorType)?.scopeFor ?: IScope.NULLSCOPE
					/*
					 * Grammar path: ErrorModelSubclause -> EMV2PropertyAssociation -> EMV2Path ->
					 * 		EMV2PathElementOrKind -> EMV2PathElement
					 */
					ErrorPropagation case
						parent.getContainerOfType(EMV2Path) != null &&
						parent.getContainerOfType(ErrorModelSubclause) != null: {
							val name = previous.propagationName
							val propagations = previous.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter[propagationName == name]
							propagations.map[typeSet.typeTokens].flatten.filter[type.size == 1].map[type.head].filter(ErrorType).scopeFor
						}
					Subcomponent: {
						val classifier = previous.allClassifier
						if (classifier != null) {
							val List<Subcomponent> subcomponents = if (classifier instanceof ComponentImplementation) {
								classifier.allSubcomponents
							} else {
								emptyList
							}
							val featureGroups = classifier.allFeatures.filter(FeatureGroup)
							val propagations = classifier.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter[
								!not && direction == DirectionType.OUT && featureorPPRef.next == null && featureorPPRef.featureorPP.name != null
							]
							val propagationsScope = new SimpleScope(propagations.map[EObjectDescription.create(featureorPPRef.featureorPP.name, it)], true)
							(subcomponents + featureGroups).scopeFor(propagationsScope)
						} else {
							IScope.NULLSCOPE
						}
					}
					FeatureGroup: {
						val featureGroups = previous.allFeatureGroupType?.allFeatures?.filter(FeatureGroup) ?: emptyList
						val previousFeatureGroups = newArrayList(previous)
						var currentPathElement = parent.eContainer
						while (currentPathElement instanceof EMV2PathElement && (currentPathElement as EMV2PathElement).namedElement instanceof FeatureGroup) {
							previousFeatureGroups.add(0, (currentPathElement as EMV2PathElement).namedElement as FeatureGroup)
							currentPathElement = currentPathElement.eContainer
						}
						val previousPath = previousFeatureGroups.map[it.name].join(".") + "."
						val lookForSubcomponentInEMV2PathElement = currentPathElement.getContainerOfType(ErrorBehaviorTransition) != null ||
							currentPathElement.getContainerOfType(OutgoingPropagationCondition) != null ||
							currentPathElement.getContainerOfType(ErrorDetection) != null
						val previousSubcomponent = if (lookForSubcomponentInEMV2PathElement) {
							if (currentPathElement instanceof EMV2PathElement) {
								currentPathElement.namedElement as Subcomponent
							}
						} else {
							val emv2Path = currentPathElement.getContainerOfType(EMV2Path)
							if (emv2Path?.containmentPath != null) {
								var lastContainmentPath = emv2Path.containmentPath
								while (lastContainmentPath.path != null) {
									lastContainmentPath = lastContainmentPath.path
								}
								if (lastContainmentPath.namedElement instanceof Subcomponent) {
									lastContainmentPath.namedElement as Subcomponent
								}
							}
						}
						val propagations = if (previousSubcomponent == null) {
							parent.allContainingClassifierEMV2Subclauses.map[propagations].flatten
						} else {
							previousSubcomponent.allClassifier?.allContainingClassifierEMV2Subclauses?.map[propagations]?.flatten ?: emptyList
						}
						val filteredPropagations = propagations.filter[
							val name = propagationName
							if (name.startsWith(previousPath)) {
								val remainingName = name.substring(previousPath.length)
								!remainingName.empty && !remainingName.contains(".")
							} else {
								false
							}
						]
						val propagationsScope = new SimpleScope(filteredPropagations.map[EObjectDescription.create(propagationName.split("\\.").last, it)], true)
						featureGroups.scopeFor(propagationsScope)
					}
				}
			}
			default: IScope.NULLSCOPE
		}
	}
	
	def private static getAllContainers(EObject object) {
		val containers = newArrayList
		for (var current = object.eContainer; current != null; current = current.eContainer) {
			containers += current
		}
		containers
	}
	
	def scope_EMV2PathElement_errorType(EMV2PathElement context, EReference reference) {
		val propagations = context.allContainingClassifierEMV2Subclauses.map[propagations].flatten
		val filteredPropagations = propagations.filter[kind == context.emv2PropagationKind]
		val typeTokens = filteredPropagations.map[typeSet.typeTokens].flatten
		typeTokens.filter[type.size == 1].map[type.head].filter(ErrorType).scopeFor
	}

	def scope_ErrorType(ErrorModelLibrary context, EReference reference) {
		scopeForErrorTypes(context.useTypes, Optional.of(context), [allErrorTypes])
	}

	def scope_TypeSet_aliasedType(ErrorModelLibrary context, EReference reference) {
		scopeForErrorTypes(context.useTypes, Optional.of(context), [allTypesets])
	}

	def scope_TypeToken_type(ErrorModelLibrary context, EReference reference) {
		scopeForErrorTypes(context.useTypes, Optional.of(context), [allErrorTypes + allTypesets])
	}

	def scope_TypeToken_type(ErrorBehaviorStateMachine context, EReference reference) {
		scopeForErrorTypes(context.useTypes, Optional.empty, [allErrorTypes + allTypesets])
	}

	def scope_TypeToken_type(TypeMappingSet context, EReference reference) {
		scopeForErrorTypes(context.useTypes, Optional.empty, [allErrorTypes + allTypesets])
	}

	def scope_TypeToken_type(TypeTransformationSet context, EReference reference) {
		scopeForErrorTypes(context.useTypes, Optional.empty, [allErrorTypes + allTypesets])
	}

	def scope_TypeToken_type(ErrorModelSubclause context, EReference reference) {
		scopeForErrorTypes(EMV2Util.getUseTypes(context), Optional.empty, [allErrorTypes + allTypesets])
	}

	def scope_FeatureorPPReference_featureorPP(FeatureorPPReference context, EReference reference) {
		switch parent : context.eContainer {
			ErrorPropagation: {
				val classifier = parent.getContainerOfType(Classifier)
				(classifier.getAllFeatures + classifier.allPropagationPoints + if (classifier instanceof ComponentImplementation) {
					classifier.allInternalFeatures
				} else {
					emptyList
				}).scopeFor
			}
			FeatureorPPReference: switch previous : parent.featureorPP {
				FeatureGroup: previous.featureGroupType.getAllFeatures.scopeFor
				default: IScope.NULLSCOPE
			}
		}
	}

	def scope_ErrorSource_outgoing(Classifier context, EReference reference) {
		context.scopeForErrorPropagation(DirectionType.OUT)
	}

	def scope_ErrorSource_failureModeReference(ErrorModelSubclause context, EReference reference) {
		val typesets = context.useTypes.map[allTypesets].flatten
		val behaviorStates = context.useBehavior.states ?: <ErrorBehaviorState>emptyList;
		(typesets + behaviorStates).scopeFor
	}

	def scope_ErrorSink_incoming(Classifier context, EReference reference) {
		context.scopeForErrorPropagation(DirectionType.IN)
	}

	def scope_ErrorPath_incoming(Classifier context, EReference reference) {
		context.scopeForErrorPropagation(DirectionType.IN)
	}

	def scope_ErrorPath_outgoing(Classifier context, EReference reference) {
		context.scopeForErrorPropagation(DirectionType.OUT)
	}

	def scope_QualifiedPropagationPoint_propagationPoint(QualifiedPropagationPoint context, EReference reference) {
		val lastSubcomponentClassifier = context.subcomponent.subcomponent.allClassifier
		if (lastSubcomponentClassifier != null) {
			val allSubclauses = lastSubcomponentClassifier.allContainingClassifierEMV2Subclauses
			allSubclauses.map[points].flatten.scopeFor
		} else {
			IScope.NULLSCOPE
		}
	}

	def scope_RepairEvent_eventInitiator(Classifier context, EReference reference) {
		context.allMembers.filterRefined.scopeFor
	}

	def scope_RepairEvent_eventInitiator(ErrorBehaviorStateMachine context, EReference reference) {
		IScope.NULLSCOPE
	}

	def scope_RecoverEvent_eventInitiator(Classifier context, EReference reference) {
		context.allMembers.filterRefined.scopeFor
	}

	def scope_RecoverEvent_eventInitiator(ErrorBehaviorStateMachine context, EReference reference) {
		IScope.NULLSCOPE
	}

	def scope_ErrorBehaviorState(ErrorBehaviorStateMachine context, EReference reference) {
		context.states.scopeFor
	}

	def scope_ErrorBehaviorState(Classifier context, EReference reference) {
		val stateMachine = context.allContainingClassifierEMV2Subclauses.map[useBehavior].filterNull.head
		stateMachine?.states?.scopeFor ?: IScope.NULLSCOPE
	}

	def scope_ConnectionErrorSource_connection(ComponentImplementation context, EReference reference) {
		context.allConnections.scopeFor
	}

	def scope_OutgoingPropagationCondition_outgoing(Classifier context, EReference reference) {
		context.scopeForErrorPropagation(DirectionType.OUT)
	}

	def scope_ErrorDetection_detectionReportingPort(Classifier context, EReference reference) {
		val features = context.getAllFeatures.filter(TriggerPort)
		val internalFeatures = if (context instanceof ComponentImplementation) {
				context.allInternalFeatures
			} else {
				emptySet
			}
		(features + internalFeatures).scopeFor
	}

	def scope_ErrorStateToModeMapping_mappedModes(ComponentClassifier context, EReference reference) {
		context.allModes.scopeFor
	}

	def scope_QualifiedErrorBehaviorState_state(QualifiedErrorBehaviorState context, EReference reference) {
		val subcomponentClassifier = context.subcomponent.subcomponent.allClassifier
		val stateMachine = subcomponentClassifier?.allContainingClassifierEMV2Subclauses?.map[useBehavior]?.filterNull?.
			head
		stateMachine?.states?.scopeFor ?: IScope.NULLSCOPE
	}

	def scope_SubcomponentElement_subcomponent(QualifiedErrorBehaviorState context, EReference reference) {
		switch parent : context.eContainer {
			QualifiedErrorBehaviorState: switch subcomponentClassifier : parent.subcomponent.subcomponent.allClassifier {
				ComponentImplementation: subcomponentClassifier.allSubcomponents.scopeFor
				default: IScope.NULLSCOPE
			}
			default: parent.getContainerOfType(ComponentImplementation)?.allSubcomponents?.scopeFor ?: IScope.NULLSCOPE
		}
	}
	
	def scope_SubcomponentElement_subcomponent(QualifiedPropagationPoint context, EReference reference) {
		switch parent : context.eContainer {
			QualifiedPropagationPoint: switch subcomponentClassifier : parent.subcomponent.subcomponent.allClassifier {
				ComponentImplementation: subcomponentClassifier.allSubcomponents.scopeFor
				default: IScope.NULLSCOPE
			}
			default: parent.getContainerOfType(ComponentImplementation)?.allSubcomponents?.scopeFor ?: IScope.NULLSCOPE
		}
	}

	def private scopeWithoutEMV2Prefix(EObject context, EReference reference) {
		new SimpleScope(delegateGetScope(context, reference).allElements.map [
			val nameAsString = name.toString("::")
			if (nameAsString.startsWith(ErrorModelCrossReferenceSerializer.PREFIX)) {
				val strippedName = nameAsString.substring(ErrorModelCrossReferenceSerializer.PREFIX.length)
				EObjectDescription.create(qualifiedNameConverter.toQualifiedName(strippedName), EObjectOrProxy)
			} else {
				it
			}
		], true)
	}

	/*
	 * The general rule of this scope is that ErrorTypes must be referred to by their simple name, not a qualified name.
	 * A qualified name is only legal if it is used to disambiguate two different ErrorTypes with the same name coming
	 * from different ErrorModelLibraries in the useTypes.  In the event of a naming conflict, a reference to an ErrorTypes
	 * is qualified with the name of the appropriate library listed in the useTypes.  This may not be the same as the
	 * library which contains the ErrorTypes definition.
	 * 
	 * This probably needs to be redesigned.  It may be better to include all simple names and all qualified names in the
	 * scope and then have the validator place errors on ambiguous simple names and warnings on unnecessary qualified names.
	 */
	def private static scopeForErrorTypes(Iterable<ErrorModelLibrary> useTypes,
		Optional<ErrorModelLibrary> parentLibrary, (ErrorModelLibrary)=>Iterable<? extends ErrorTypes> elementGetter) {
		val useTypesPerLib = newHashMap(useTypes.map[libraryName -> elementGetter.apply(it).toSet])

		val contextErrorTypes = parentLibrary.map[elementGetter.apply(it).toSet]
		val partitionResult = (useTypesPerLib.values.flatten + contextErrorTypes.orElse(emptySet)).toSet.groupBy [
			name.toLowerCase
		].values.stream.collect(Collectors.partitioningBy[size == 1])

		// Add simple names to the scope for all ErrorTypes that do not have a naming conflict.
		val noConflictsDescriptions = partitionResult.get(true).flatten.map [
			EObjectDescription.create(QualifiedName.create(name), it)
		]

		val conflictsDescriptions = partitionResult.get(false).map [
			map[
				if (contextErrorTypes.present && contextErrorTypes.get.contains(it)) {
					// For ErrorTypes that are locally contained in parentLibrary or are in the extends hierarchy, they are referred to by their simple name.
					#[EObjectDescription.create(QualifiedName.create(name), it)]
				} else {
					/*
					 * For conflicting ErrorTypes that are contributed by the useTypes, they are qualified by the library names
					 * listed in the useTypes which contributes this ErrorTypes.
					 */
					useTypesPerLib.filter[libraryName, visibleErrorTypes|visibleErrorTypes.contains(it)].keySet.map [ libraryName |
						EObjectDescription.create(QualifiedName.create(libraryName, name), it)
					]
				}
			]
		].flatten.flatten

		new SimpleScope(noConflictsDescriptions + conflictsDescriptions, true)
	}

	def public static eDescriptionsForErrorPropagation(Classifier context, DirectionType requiredDirection) {
		val propagations = context.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter [
			!not && direction == requiredDirection
		]
		propagations.map[EObjectDescription.create(propagationName, it)]
	}

	def public static scopeForErrorPropagation(Classifier context, DirectionType requiredDirection) {
		val propagations = context.allContainingClassifierEMV2Subclauses.map[propagations].flatten.filter [
			!not && direction == requiredDirection
		]
		new SimpleScope(propagations.map[EObjectDescription.create(propagationName, it)], true)
	}

	def public static getEventandIncomingPropagationDescriptions(Classifier classifier) {
		val stateMachine = classifier?.allContainingClassifierEMV2Subclauses?.map[useBehavior]?.filterNull?.head
		val ebsmevents = stateMachine?.events
		val ebsmeventDescriptions = ebsmevents?.map[EObjectDescription.create(QualifiedName.create(name), it)] ?: emptyList
		classifier.allContainingClassifierEMV2Subclauses.map [
			val eventsDescriptions = events.map[EObjectDescription.create(QualifiedName.create(name), it)]
			val flowDescriptions = flows.map[EObjectDescription.create(QualifiedName.create(name), it)]
			val inPropagations = propagations.filter[!not && direction == DirectionType.IN]
			val propagationsDescriptions = inPropagations.map [
				EObjectDescription.create(QualifiedName.create(propagationName), it)
			]
			eventsDescriptions + flowDescriptions + propagationsDescriptions
		].flatten + ebsmeventDescriptions
	}

	def private static Iterable<IEObjectDescription> getSubcomponentPropagations(String prefix,
		ComponentClassifier classifier) {
		val propagationsDescriptions = classifier.allContainingClassifierEMV2Subclauses.map [
			val outPropagations = propagations.filter[!not && direction == DirectionType.OUT]
			outPropagations.map[EObjectDescription.create(QualifiedName.create(prefix + propagationName), it)]
		].flatten

		val nextSubcomponentLevel = if (classifier instanceof ComponentImplementation) {
				val validSubcomponents = classifier.allSubcomponents.filter[allClassifier != null]
				validSubcomponents.map[getSubcomponentPropagations(prefix + name + ".", allClassifier)].flatten
			} else {
				emptySet
			}

		propagationsDescriptions + nextSubcomponentLevel
	}
}