package org.osate.xtext.aadl2.errormodel.util;

import java.util.Collection;
import java.util.List;

import org.eclipse.emf.common.util.BasicEList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.UniqueEList;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelFactory;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelLibrary;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorType;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorTypes;
import org.osate.xtext.aadl2.errormodel.errorModel.TypeMapping;
import org.osate.xtext.aadl2.errormodel.errorModel.TypeMappingSet;
import org.osate.xtext.aadl2.errormodel.errorModel.TypeSet;
import org.osate.xtext.aadl2.errormodel.errorModel.TypeToken;
import org.osate.xtext.aadl2.errormodel.errorModel.TypeTransformation;
import org.osate.xtext.aadl2.errormodel.errorModel.TypeTransformationSet;

public class EM2TypeSetUtil {

	/**
	 * return the root ErrorType of ErrorType et
	 * @param et ErrorType
	 * @return ErrorType root
	 */
	public static ErrorType rootType(ErrorType et) {
		while (et.getSuperType() != null) {
			et = EMV2Util.resolveAlias(et.getSuperType());
		}
		return et;
	}

	/**
	 * true if both error types are in the same type hierarchy
	 * @param et1 ErrorType
	 * @param et2 ErrorType
	 * @return boolean
	 */
	public static boolean inSameTypeHierarchy(ErrorType et1, ErrorType et2) {
		return rootType(et1) == rootType(et2);// XXX assumes the root types are not aliases. Assured by rootType
	}

	/**
	 * true if error type t1 is same type as t2
	 * @param t1
	 * @param t2
	 * @return
	 */
	public static boolean isSame(ErrorType t1, ErrorType t2) {
		return EMV2Util.resolveAlias(t1) == EMV2Util.resolveAlias(t2);
	}

	/**
	 * true if error type is an alias
	 * @param et
	 * @return
	 */
	public static boolean isAlias(ErrorType et) {
		return et.getAliasedType() != null;
	}

	/**
	 * true if error type set is an alias
	 * @param et
	 * @return
	 */
	public static boolean isAlias(TypeSet ts) {
		return ts.getAliasedType() != null;
	}

	/**
	 * true if super type contains type as subtype
	 * aliases are resolved before the error types are compared
	 * @param supertype
	 * @param type
	 * @return boolean
	 */
	public static boolean contains(ErrorType supertype, ErrorType type) {
		if (supertype == null || type == null) {
			return false;
		}
		ErrorType resolvedtype = EMV2Util.resolveAlias(type);
		ErrorType resolvedsupertype = EMV2Util.resolveAlias(supertype);
		while (resolvedtype != null) {
			if (resolvedtype == resolvedsupertype) {
				return true;
			} else {
				resolvedtype = EMV2Util.resolveAlias(resolvedtype.getSuperType());
			}
		}
		return false;
	}

	public static boolean contains(ErrorTypes constraint, ErrorType type) {
		if (constraint instanceof ErrorType) {
			return contains((ErrorType) constraint, type);
		}
		if (constraint instanceof TypeSet) {
			return contains((TypeSet) constraint, type);
		}
		return false;
	}

	public static boolean contains(ErrorTypes constraint, TypeSet type) {
		if (constraint instanceof ErrorType) {
			return contains((ErrorType) constraint, type);
		}
		if (constraint instanceof TypeSet) {
			return contains((TypeSet) constraint, type);
		}
		return false;
	}

	public static boolean contains(ErrorType constraint, TypeSet ts) {
		ts = EMV2Util.resolveAlias(ts);
		for (TypeToken tselement : ts.getTypeTokens()) {
			if (!contains(constraint, tselement)) {
				return false;
			}
		}
		return true;
	}

	public static boolean contains(ErrorType constraint, TypeToken token) {
		if (constraint == null || token == null) {
			return false;
		}
		if (token.isNoError()) {
			return false;
		}
		EList<ErrorTypes> tsetype = token.getType();
		for (ErrorTypes errorType : tsetype) {
			if (contains(constraint, errorType)) {
				return true;
			}
		}
		return false;
	}

	public static boolean contains(TypeToken constraint, ErrorTypes type) {
		if (type instanceof ErrorType) {
			return contains(constraint, (ErrorType) type);
		}
		if (type instanceof TypeSet) {
			return contains(constraint, (TypeSet) type);
		}
		return true;
	}

	public static boolean contains(ErrorTypes constraint, TypeToken type) {
		if (constraint instanceof ErrorType) {
			return contains((ErrorType) constraint, type);
		}
		if (constraint instanceof TypeSet) {
			return contains((TypeSet) constraint, type);
		}
		return true;
	}

	public static boolean contains(ErrorTypes constraint, ErrorTypes type) {
		if (type instanceof ErrorType) {
			ErrorType et = (ErrorType) type;
			return contains(constraint, et);
		}
		if (type instanceof TypeSet) {
			TypeSet ts = (TypeSet) type;
			return contains(constraint, ts);
		}
		return false;
	}

	/**
	 * true if TypeToken constraint contains ErrorType type as one of its product elements
	 * aliases are resolved before the error types are compared
	 * @param constraint TypeToken
	 * @param type ErrorType
	 * @return
	 */
	public static boolean contains(TypeToken constraint, ErrorType type) {
		if (constraint == null || type == null) {
			return false;
		}
		if (constraint.isNoError()) {
			return false;
		}
		EList<ErrorTypes> tsetype = constraint.getType();
		for (ErrorTypes errorType : tsetype) {
			if (contains(errorType, type)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * true if TypeToken constraint contains TypeToken token
	 * aliases are resolved before the error types are compared
	 * @param constraint TypeToken
	 * @param token TypeToken
	 * @return
	 */
	public static boolean contains(TypeToken constraint, TypeToken token) {
		if (constraint == null || token == null) {
			return false;
		}
		if (token.isNoError()) {
			return true;
		}
		if (constraint.isNoError()) {
			if (token.isNoError()) {
				return true;
			}
			return false;
		}
		if (constraint.getType().size() != token.getType().size()) {
			if (constraint.getType().size() == 1) {
				// the constraint is a single type set
				ErrorTypes ts = constraint.getType().get(0);
				if (ts instanceof TypeSet) {
					return contains((TypeSet) ts, token);
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		for (ErrorTypes errorType : token.getType()) {
			if (!contains(constraint, errorType)) {
				return false;
			}
		}
		return true;
	}

	/**
	 * true if TypeSet ts contains TypeToken token
	 * The type set can represent a constraint
	 * aliases are resolved before the error types are compared
	 * @param ts TypeSet
	 * @param token TypeToken
	 * @return boolean
	 */
	public static boolean contains(TypeSet ts, TypeToken token) {
		if (ts == null || token == null) {
			return false;
		}
		if (token.isNoError()) {
			return true;
		}
		ts = EMV2Util.resolveAlias(ts);
		int toksize = token.getType().size();
		for (TypeToken tselement : ts.getTypeTokens()) {
			if (tselement.getType().size() == toksize) { // || tselement.getType().get(0) instanceof TypeSet) {
				if (contains(tselement, token)) {
					return true;
				}
			}
		}
		return false;
	}

	/**
	 * true if TypeSet ts contains TypeToken token
	 * The type set can represent a constraint
	 * aliases are resolved before the error types are compared
	 * @param ts TypeSet
	 * @param token TypeToken
	 * @return boolean
	 */
	public static boolean contains(TypeToken token, TypeSet ts) {
		if (ts == null || token == null) {
			return false;
		}
		if (token.isNoError()) {
			return false;
		}
		ts = EMV2Util.resolveAlias(ts);
		for (ErrorTypes et : token.getType()) {
			if (contains(et, ts)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * true if TypeSet ts contains ErrorType et
	 * The type set can represent a constraint
	 * aliases are resolved before the error types are compared
	 * @param ts TypeSet
	 * @param et ErrorType
	 * @return boolean
	 */
	public static boolean contains(TypeSet ts, ErrorType et) {
		if (ts == null || et == null) {
			return false;
		}
		ts = EMV2Util.resolveAlias(ts);
		for (TypeToken tselement : ts.getTypeTokens()) {
			if (contains(tselement, et)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * true if TypeSet ts contains TypeSet subts
	 * The type set can represent a constraint, i.e., product types, and Type matching are taken into account
	 * aliases are resolved before the error types are compared
	 * @param ts TypeSet
	 * @param subts TypeSet
	 * @return boolean
	 */
	public static boolean contains(TypeSet ts, TypeSet subts) {
		if (ts == null || subts == null) {
			return false;
		}
		ts = EMV2Util.resolveAlias(ts);
		subts = EMV2Util.resolveAlias(subts);
		if (ts == subts)
			return true;
		EList<TypeToken> subelements = subts.getTypeTokens();
		for (TypeToken typeToken : subelements) {
			if (!contains(ts, typeToken)) {
				return false;
			}
		}
		return true;
	}

	/**
	 * returns all tokens that are common to both type sets
	 * aliases are resolved before the error types are compared
	 * @param ts1 TypeSet
	 * @param ts2 TypeSet
	 * @return list TypeToken
	 */
	public static BasicEList<TypeToken> getTypeSetIntersection(TypeSet ts1, TypeSet ts2) {
		BasicEList<TypeToken> result = new BasicEList<TypeToken>();
		if (ts1 == null || ts2 == null) {
			return result;
		}
		ts1 = EMV2Util.resolveAlias(ts1);
		ts2 = EMV2Util.resolveAlias(ts2);
		if (ts1 == ts2) {
			result.addAll(ts1.getTypeTokens());
			return result;
		}
		for (TypeToken tselement1 : ts1.getTypeTokens()) {
			int toksize = tselement1.getType().size();
			for (TypeToken tselement2 : ts2.getTypeTokens()) {
				if (tselement2.getType().size() == toksize) {
					getConstrainedTypeTokens(tselement1, tselement2, result);
				}
			}
		}
		return result;
	}

	/**
	 * returns all subtypes of the token that are in TypeSet ts
	 * The type set can represent a constraint
	 * aliases are resolved before the error types are compared
	 * @param ts TypeSet
	 * @param token TypeToken
	 * @return list TypeToken
	 */
	public static Collection<TypeToken> getConstrainedTypeTokens(TypeSet ts, TypeToken token) {
		BasicEList<TypeToken> result = new BasicEList<TypeToken>();
		if (token == null) {
			return result;
		}
		if (ts == null) {
			result.add(token);
			return result;
		}
		ts = EMV2Util.resolveAlias(ts);
		int toksize = token.getType().size();
		for (TypeToken tselement : ts.getTypeTokens()) {
			if (tselement.getType().size() == toksize) {
				getConstrainedTypeTokens(tselement, token, result);
			}
		}
		return result;
	}

	/**
	 * adds a type token that has the subtype of each product element of the two tokens
	 * The subtype can be from the constraint or the token
	 * The TypeToken error type lists are assumed to be of the same size
	 * @param ts TypeSet
	 * @param token TypeToken
	 * @param result List of type tokens
	 */
	protected static void getConstrainedTypeTokens(TypeToken constraint, TypeToken token,
			Collection<TypeToken> result) {
		int toksize = token.getType().size();
		EList<ErrorTypes> toklist = token.getType();
		EList<ErrorTypes> conlist = constraint.getType();
		TypeToken tt = ErrorModelFactory.eINSTANCE.createTypeToken();
		for (int i = 0; i < toksize; i++) {
			ErrorTypes toktype = toklist.get(i);
			ErrorTypes contype = conlist.get(i);
			if (contains(toktype, contype)) {
				tt.getType().add(contype);
			} else if (contains(contype, toktype)) {
				tt.getType().add(toktype);
			} else {
				return;
			}
		}
		result.add(tt);
		return;
	}

	/**
	 * add type token for specified error type to newItems. Then add a token
	 * for each token in existing list with error type added.
	 * @param newItems list holding the newly added tokens
	 * @param etlist error subtypes of the next product element to be added
	 * @return result list
	 */
	protected static EList<TypeToken> addItemSet(EList<TypeToken> newItems, EList<ErrorType> etlist) {
		EList<TypeToken> result = new BasicEList<TypeToken>();
		for (TypeToken typeToken : newItems) {
			for (ErrorType et : etlist) {
				TypeToken tu = EcoreUtil.copy(typeToken);
				tu.getType().add(et);
				result.add(tu);
			}
		}
		return result;
	}

	/**
	 * generate all type tokens for a given typeset.
	 * Do so for each leaf subtype.
	 * @param typeSet
	 * @return list of type tokens
	 */
	public static EList<TypeToken> generateAllLeafTypeTokens(TypeSet typeSet, List<ErrorModelLibrary> usetypes) {
		EList<TypeToken> result = new BasicEList<TypeToken>();
		if (typeSet == null) {
			return result;
		}
		EList<TypeToken> typelist = typeSet.getTypeTokens();
		for (TypeToken typeSetElement : typelist) {
			// add all leaf nodes
			EList<TypeToken> newitems = new BasicEList<TypeToken>();
			EList<ErrorTypes> elementtypes = typeSetElement.getType();
			for (ErrorTypes errorType : elementtypes) {
				if (errorType instanceof ErrorType) {
					// elements of a product type
					EList<ErrorType> etlist = getAllLeafSubTypes((ErrorType) errorType, usetypes);
					if (newitems.isEmpty()) {
						// first/single type: add all leaves
						for (ErrorType subType : etlist) {
							TypeToken token = ErrorModelFactory.eINSTANCE.createTypeToken();
							token.getType().add(subType);
							newitems.add(token);
						}
					} else {
						// product type: add other type elements from the product type
						newitems = addItemSet(newitems, etlist);
					}
				}
			}
			result.addAll(newitems);
			newitems.clear();
		}
		return result;
	}

	/**
	 * Get all error types that are direct subtypes of et or any of its aliases.
	 * If et is an alias we only find subtypes of the alias or its aliases
	 * We look for any error type accessible in the TypeUseContext, i.e., subclause, type library, type mapping/xform set
	 * @param et
	 * @param tuc
	 * @return
	 */
	public static EList<ErrorType> getSubTypes(ErrorType et, List<ErrorModelLibrary> usetypes) {
		UniqueEList<ErrorType> result = new UniqueEList<ErrorType>();
		ErrorType resolvedet = EMV2Util.resolveAlias(et);
		for (ErrorModelLibrary etl : usetypes) {
			EList<ErrorType> typeslist = etl.getTypes();
			for (ErrorType suberrortype : typeslist) {
				// check if type is a subtype or an alias for which we need to check for subtypes
				ErrorType resolvedSubErrorType = EMV2Util.resolveAlias(suberrortype);
				if (resolvedSubErrorType == resolvedet) {
					// subtype is an alias of ET. need to look for its subtypes
					EList<ErrorType> aliasresult = getSubTypes(suberrortype, usetypes);
					result.addAll(aliasresult);
				}
				if (suberrortype.getSuperType() == et) {
					result.add(suberrortype);
				}
				ErrorType aliasedsubtype = suberrortype;
				while (isAlias(aliasedsubtype)) {
					// see if the alias origin is a subtype
					ErrorType sub = aliasedsubtype.getAliasedType();
					if (sub.getSuperType() == et) {
						result.add(sub);
					} else {
						aliasedsubtype = sub;
					}
				}
			}
		}
		return result;
	}

	/**
	 * get list of leaf subtypes of the given error type et excluding et itself
	 * Each any error type alias has been resolved
	 * @param context
	 * @param et
	 * @return
	 */
	public static EList<ErrorType> getAllLeafSubTypes(ErrorType et, List<ErrorModelLibrary> usetypes) {
		EList<ErrorType> result = new UniqueEList<ErrorType>();
		EList<ErrorType> removeMe = new UniqueEList<ErrorType>();
		for (ErrorModelLibrary etl : usetypes) {
			EList<ErrorType> typeslist = etl.getTypes();
			for (ErrorType errorType : typeslist) {
				ErrorType set = EMV2Util.resolveAlias(errorType);
				if (contains(et, set)) {
					result.add(set);
				}
				if (set.getSuperType() != null) {
					removeMe.add(set.getSuperType());
				}
			}
		}
		result.removeAll(removeMe);
		return result;
	}

	/**
	 * map a TypeToken into a target type token according to the TypeMappingSet.
	 * The original token is not modified.
	 * The result token is currently that from the mapping rule and is not expected to be modified
	 * @param token TypeToken
	 * @param tms TypeMappingSet
	 * @return result TypeToken or null if no mapping
	 */
	public static TypeToken mapTypeToken(TypeToken token, TypeMappingSet tms) {
		EList<TypeMapping> tmlist = tms.getMapping();
		for (TypeMapping typeMapping : tmlist) {
			TypeSet src = typeMapping.getSource();
			if (contains(src, token)) {
				return typeMapping.getTarget().getTypeTokens().get(0);
			}
		}
		return null;
	}

	public static TypeToken mapTypeToken(ErrorTypes token, TypeMappingSet tms) {
		EList<TypeMapping> tmlist = tms.getMapping();
		for (TypeMapping typeMapping : tmlist) {
			TypeSet src = typeMapping.getSource();
			if (contains(src, token)) {
				return typeMapping.getTarget().getTypeTokens().get(0);
			}
		}
		return null;
	}

	/**
	 * map a TypeToken from the target type token to the first type token in the source type set according to the TypeMappingSet.
	 * The original token is not modified.
	 * The result token is currently that from the mapping rule and is not expected to be modified
	 * @param token TypeToken
	 * @param tms TypeMappingSet
	 * @return result TypeToken or null if no mapping found
	 */
	public static TypeToken reverseMapTypeToken(TypeToken token, TypeMappingSet tms) {
		EList<TypeMapping> tmlist = tms.getMapping();
		for (TypeMapping typeMapping : tmlist) {
			TypeSet src = typeMapping.getSource();
			TypeSet trg = typeMapping.getTarget();
			if (contains(trg, token)) {
				return src.getTypeTokens().get(0);
			}
		}
		return null;
	}

	/**
	 * map a TypeToken into a target type token according to the TypeTransformationSet.
	 * The original token is not modified.
	 * The result token is currently that from the mapping rule and is not expected to be modified
	 * @param token TypeToken
	 * @param tts TypeTransformationSet
	 * @return result TypeToken
	 */
	public static TypeToken mapTypeToken(TypeToken token, TypeTransformationSet tts) {
		EList<TypeTransformation> ttlist = tts.getTransformation();
		for (TypeTransformation typeXform : ttlist) {
			TypeSet src = typeXform.getSource();
			if (contains(src, token)) {
				return typeXform.getTarget().getTypeTokens().get(0);
			}
		}
		return null;
	}

	/**
	 * map a TypeToken into a target type token according to the TypeTransformationSet.
	 * The original token is not modified.
	 * The result token is currently that from the mapping rule and is not expected to be modified
	 * @param srctoken TypeToken
	 * @param contributortoken TypeToken
	 * @param tts TypeTransformationSet
	 * @return result TypeToken
	 */
	public static TypeToken mapTypeToken(TypeToken srctoken, TypeToken contributortoken, TypeTransformationSet tts) {
		EList<TypeTransformation> ttlist = tts.getTransformation();
		for (TypeTransformation typeXform : ttlist) {
			TypeSet src = typeXform.getSource();
			TypeSet contrib = typeXform.getContributor();
			if (contains(src, srctoken) && contains(contrib, contributortoken)) {
				return typeXform.getTarget().getTypeTokens().get(0);
			}
		}
		return null;
	}

}
