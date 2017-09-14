/**
 */
package org.osate.xtext.aadl2.errormodel.errorModel.impl;

import org.eclipse.emf.common.notify.Notification;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl;

import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelPackage;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelSubclause;
import org.osate.xtext.aadl2.errormodel.errorModel.ErrorModelSubclauseReferenceDummy;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Subclause Reference Dummy</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * </p>
 * <ul>
 *   <li>{@link org.osate.xtext.aadl2.errormodel.errorModel.impl.ErrorModelSubclauseReferenceDummyImpl#getXref <em>Xref</em>}</li>
 * </ul>
 *
 * @generated
 */
public class ErrorModelSubclauseReferenceDummyImpl extends MinimalEObjectImpl.Container implements ErrorModelSubclauseReferenceDummy
{
  /**
   * The cached value of the '{@link #getXref() <em>Xref</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getXref()
   * @generated
   * @ordered
   */
  protected ErrorModelSubclause xref;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected ErrorModelSubclauseReferenceDummyImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass()
  {
    return ErrorModelPackage.Literals.ERROR_MODEL_SUBCLAUSE_REFERENCE_DUMMY;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public ErrorModelSubclause getXref()
  {
    if (xref != null && xref.eIsProxy())
    {
      InternalEObject oldXref = (InternalEObject)xref;
      xref = (ErrorModelSubclause)eResolveProxy(oldXref);
      if (xref != oldXref)
      {
        if (eNotificationRequired())
          eNotify(new ENotificationImpl(this, Notification.RESOLVE, ErrorModelPackage.ERROR_MODEL_SUBCLAUSE_REFERENCE_DUMMY__XREF, oldXref, xref));
      }
    }
    return xref;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public ErrorModelSubclause basicGetXref()
  {
    return xref;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public void setXref(ErrorModelSubclause newXref)
  {
    ErrorModelSubclause oldXref = xref;
    xref = newXref;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, ErrorModelPackage.ERROR_MODEL_SUBCLAUSE_REFERENCE_DUMMY__XREF, oldXref, xref));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType)
  {
    switch (featureID)
    {
      case ErrorModelPackage.ERROR_MODEL_SUBCLAUSE_REFERENCE_DUMMY__XREF:
        if (resolve) return getXref();
        return basicGetXref();
    }
    return super.eGet(featureID, resolve, coreType);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eSet(int featureID, Object newValue)
  {
    switch (featureID)
    {
      case ErrorModelPackage.ERROR_MODEL_SUBCLAUSE_REFERENCE_DUMMY__XREF:
        setXref((ErrorModelSubclause)newValue);
        return;
    }
    super.eSet(featureID, newValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eUnset(int featureID)
  {
    switch (featureID)
    {
      case ErrorModelPackage.ERROR_MODEL_SUBCLAUSE_REFERENCE_DUMMY__XREF:
        setXref((ErrorModelSubclause)null);
        return;
    }
    super.eUnset(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public boolean eIsSet(int featureID)
  {
    switch (featureID)
    {
      case ErrorModelPackage.ERROR_MODEL_SUBCLAUSE_REFERENCE_DUMMY__XREF:
        return xref != null;
    }
    return super.eIsSet(featureID);
  }

} //ErrorModelSubclauseReferenceDummyImpl
