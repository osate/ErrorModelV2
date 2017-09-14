/**
 */
package org.osate.xtext.aadl2.errormodel.errorModel;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Subclause Reference Dummy</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelSubclauseReferenceDummy#getXref <em>Xref</em>}</li>
 * </ul>
 *
 * @see org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelPackage#getErrorModelSubclauseReferenceDummy()
 * @model
 * @generated
 */
public interface ErrorModelSubclauseReferenceDummy extends EObject
{
  /**
   * Returns the value of the '<em><b>Xref</b></em>' reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Xref</em>' reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Xref</em>' reference.
   * @see #setXref(ErrorModelSubclause)
   * @see org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelPackage#getErrorModelSubclauseReferenceDummy_Xref()
   * @model
   * @generated
   */
  ErrorModelSubclause getXref();

  /**
   * Sets the value of the '{@link org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelSubclauseReferenceDummy#getXref <em>Xref</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Xref</em>' reference.
   * @see #getXref()
   * @generated
   */
  void setXref(ErrorModelSubclause value);

} // ErrorModelSubclauseReferenceDummy
