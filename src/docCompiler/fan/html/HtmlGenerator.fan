//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 May 07  Brian Frank  Creation
//

using compiler
using fandoc

**
** HtmlGenerator is the base class for HTML generation which
** handles all the navigation and URI concerns
**
abstract class HtmlGenerator : HtmlDocWriter, DocCompilerSupport
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(DocCompiler compiler, Loc loc, OutStream out)
    : super(out)
  {
    this.compiler = compiler
    this.loc = loc
  }

//////////////////////////////////////////////////////////////////////////
// DocCompilerSupport
//////////////////////////////////////////////////////////////////////////

  override DocCompiler compiler

//////////////////////////////////////////////////////////////////////////
// Generator
//////////////////////////////////////////////////////////////////////////

  Void generate()
  {
    compiler.htmlTheme.startPage(out, title, pathToRoot)

    out.print("<div class='subHeader'>\n")
    out.print("<div>\n")
    header
    out.print("</div>\n")
    out.print("</div>\n")

    out.print("<div class='content'>\n")
    out.print("<div>\n")
    out.print("<div class='fandoc'>\n")
    content
    out.print("</div>\n")
    out.print("<div class='sidebar'>\n")
    sidebar
    out.print("</div>\n")
    out.print("</div>\n")
    out.print("</div>\n")

    out.print("<div class='footer'>\n")
    out.print("<div>\n")
    footer
    out.print("</div>\n")
    out.print("</div>\n")

    compiler.htmlTheme.endPage(out)
  }

//////////////////////////////////////////////////////////////////////////
// Hooks
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the title for this document.
  **
  virtual Str title()
  {
    return "Fandoc"
  }

  **
  ** Returnt the relative path to the document root.
  **
  virtual Str pathToRoot()
  {
    return "../"
  }

  **
  ** Generate the header section of the document.
  **
  virtual Void header()
  {
  }

  **
  ** Generate the content section of the document.
  **
  virtual Void content()
  {
  }

  **
  ** Generate the footer section of the document.
  **
  virtual Void footer()
  {
    out.print("<p>\n")
    if (compiler.pod != null)
      out.print("$compiler.pod.name $compiler.pod.version\n");
    out.print("[$DateTime.now.toLocale]\n");
    out.print("</p>\n")
  }

  **
  ** Generate the sidebar section of the document.
  **
  virtual Void sidebar()
  {
  }

  **
  ** Generate the search box.
  **
  Void searchBox()
  {
    out.print("<div class='fandocSearch'>\n")
    out.print("<form action='' onsubmit='return false;'>\n")
    out.print("  <div>\n")
    out.print("    <input type='text' id='fandocSearchBox' value='Search...' class='hint'\n")
    out.print("     onkeyup='SearchBox.search(event);'\n");
    out.print("     onfocus='SearchBox.onfocus();' onblur='SearchBox.onblur();' />\n")
    out.print("  </div>\n")
    out.print("  <div id='fandocSearchResults'></div>\n")
    out.print("</form>\n")
    out.print("</div>\n")
  }

  **
  ** Return the display version of this string.
  **
  Str toDisplay(Str s)
  {
    if (s == "DSL")  return s
    if (s == "DSLs") return s
    if (s == "IDEs") return s
    if (s == "JavaScript") return s
    return s.toDisplayName
  }

//////////////////////////////////////////////////////////////////////////
// HtmlDocWriter
//////////////////////////////////////////////////////////////////////////

  override Void elemStart(DocElem elem)
  {
    if (elem.id === DocNodeId.link)
    {
      link := elem as Link
      if (!link.uri.endsWith(".html"))
      {
        link.uri = compiler.uriMapper.map(link.uri, loc).toStr
        link.isCode = compiler.uriMapper.targetIsCode
      }
    }

    super.elemStart(elem)
  }

//////////////////////////////////////////////////////////////////////////
// Support
//////////////////////////////////////////////////////////////////////////

  Void facets(Symbol:Obj? facets, Bool wrap := true, Bool br := true)
  {
    if (facets.size == 0) return
    if (wrap) out.print("<p><code class='sig'>")
    facets.keys.each |s|
    {
      def := facetValToStr(facets[s])
      uri := compiler.uriMapper.map("@$s.qname", loc)
      out.print("@<a href='$uri'>$s.name</a>")
      if (def != "true") out.print(" = $def")
      if (br) out.print("<br/>")
      out.print("\n")
    }
    if (wrap) out.print("</code></p>\n")
  }

  static Str facetValToStr(Obj? val)
  {
    // check if we can omit list type signature
    // if every item has exact same type
    list := val as Obj?[]
    if (list != null && !list.isEmpty)
    {
      x := list.first
      inferred := x == null ?
                  list.all { it == null } :
                  list.all { it != null && Type.of(x) == Type.of(it) }
      if (inferred) return "[" + list.join(", ") { facetValToStr(it) } + "]"
    }

    // use serialization format
    str := Buf().writeObj(val).flip.readAllStr

    // strip sys:: of simple/list types
    if (str.startsWith("sys::")) str = str[5..-1]

    return str
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Loc loc
  Str docHome := "Doc Home"
}