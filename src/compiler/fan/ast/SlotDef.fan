//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 06  Brian Frank  Creation
//

**
** SlotDef models a slot definition - a FieldDef or MethodDef
**
abstract class SlotDef : DefNode, CSlot
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, TypeDef parentDef)
    : super(loc)
  {
    this.parentDef = parentDef
  }

//////////////////////////////////////////////////////////////////////////
// DefNode
//////////////////////////////////////////////////////////////////////////

  override CNamespace ns() { return parent.ns }

//////////////////////////////////////////////////////////////////////////
// CSlot
//////////////////////////////////////////////////////////////////////////

  override CType parent() { return parentDef }
  override Str qname() { return "${parent.qname}.${name}" }

//////////////////////////////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////////////////////////////

  abstract Void walk(Visitor v, VisitDepth depth)

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  readonly TypeDef parentDef    // parent TypeDef
  override Str name             // slot name
  Bool overridden := false      // set by Inherit when successfully overridden

}