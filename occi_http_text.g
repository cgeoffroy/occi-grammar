grammar occi_http_text;

options {
  language = Java;
}

tokens{
  CATEGORY_HEADER = 'Category:';
  LINK_HEADER = 'Link:';
  ATTR_HEADER = 'X-OCCI-Attribute:';
  LOCATION_HEADER = 'X-OCCI-Location:';
  SCHEME_ATTR = 'scheme';
  CLASS_ATTR = 'class';
  TITLE_ATTR = 'title';
  REL_ATTR = 'rel';
  LOCATION_ATTR = 'location';
  ATTRIBUTES_ATTR = 'attributes';
  SELF_ATTR = 'self';
  CAT_ATTR = 'category';
  CAT_ATTR_SEP = ';';
  VAL_ASSIGN = '=';
  QUOTE = '"';
  OPEN_PATH = '<';
  CLOSE_PATH = '>';
}

@header {
  package be.edmonds.occi;
}
@lexer::header {
  package be.edmonds.occi;
}

// ----------------------------------------
// ---------- All OCCI Headers ------------
// ----------------------------------------

occi_header:
  ( category_header
  | link_header
  | attribute_header
  | location_header
  )+
  EOF
;

// ----------------------------------------
// ----------- Category Header ------------
// ----------------------------------------
/*
ABNF representation of category from the http rendering specification

  Category         = "Category" ":" #category-value [ "," #category-value]
  category-value   = term
                    ";" "scheme" "=" <"> scheme <">
                    ";" "class" "=" ( class | <"> class <"> )
                    [ ";" "title" "=" quoted-string ]
                    [ ";" "rel" "=" <"> type-identifier <"> ]
                    [ ";" "location" "=" URI ]
                    [ ";" "attributes" "=" <"> attribute-list <"> ]
                    [ ";" "actions" "=" <"> action-list <"> ]
  term             = token
  scheme           = URI
  type-identifier  = scheme term
  class            = "action" | "mixin" | "kind"
  attribute-list   = attribute-name
                   | attribute-name *( 1*SP attribute-name)
  attribute-name   = attr-component *( "." attr-component )
  attr-component   = LOALPHA *( LOALPHA | DIGIT | "-" | "_" )
  action-list      = action
                   | action *( 1*SP action)
  action           = type-identifier

Examples:

  Category: storage;
      scheme="http://schemas.ogf.org/occi/infrastructure#";
      class="kind";
      title="Storage Resource";
      rel="http://schemas.ogf.org/occi/core#resource";
      location=/storage/;
      attributes="occi.storage.size occi.storage.state";
      actions="http://schemas.ogf.org/occi/infrastructure/storage/action#resize ...";
*/
//TODO allow for multiple categories per line seperated by ','
category_header:
  CATEGORY_HEADER category_header_val
;
category_header_val:
  term_attr scheme_attr class_attr (title_attr | rel_attr | location_attr | cat_attributes_attr)*
;
term_attr:
  TOKEN
;

scheme_attr:
  CAT_ATTR_SEP SCHEME_ATTR VAL_ASSIGN QUOTE scheme_val QUOTE
;
scheme_val:
  URI
;

class_attr:
  CAT_ATTR_SEP CLASS_ATTR VAL_ASSIGN QUOTE class_val QUOTE
;
class_val:
  CLASS
;

title_attr:
  CAT_ATTR_SEP TITLE_ATTR VAL_ASSIGN QUOTE title_val QUOTE
;
title_val:
  TOKEN
;

rel_attr:
  CAT_ATTR_SEP REL_ATTR VAL_ASSIGN QUOTE rel_val QUOTE
;
rel_val:
  TOKEN
;

location_attr:
  CAT_ATTR_SEP LOCATION_ATTR VAL_ASSIGN QUOTE location_val QUOTE
;
location_val:
  TOKEN
;

cat_attributes_attr:
  CAT_ATTR_SEP ATTRIBUTES_ATTR VAL_ASSIGN QUOTE attributes_names QUOTE
;
attributes_names:
  attribute_attr_name (attribute_attr_name)*
;

// ----------------------------------------
// -------------- Link Header -------------
// ----------------------------------------
/*
ABNF representation of category from the http rendering specification

Link specification for links in general:

  Link             = "Link" ":" #link-value
  link-value       = "<" URI-Reference ">"
                    ";" "rel" "=" <"> resource-type <">
                    [ ";" "self" "=" <"> link-instance <"> ]
                    [ ";" "category" "=" link-type ]
                    *( ";" link-attribute )
  term             = token
  scheme           = URI
  type-identifier  = scheme term
  resource-type    = type-identifier *( 1*SP type-identifier )
  link-type        = type-identifier *( 1*SP type-identifier )
  link-instance    = URI-reference
  link-attribute   = attribute-name "=" ( token | quoted-string )
  attribute-name   = attr-component *( "." attr-component )
  attr-component   = LOALPHA *( LOALPHA | DIGIT | "-" | "_" )

Link specification for links that call actions:

  Link             = "Link" ":" #link-value
  link-value       = "<" action-uri ">"
                    ";" "rel" "=" <"> action-type <">
  term             = token
  scheme           = URI
  type-identifier  = scheme term
  action-type      = type-identifier
  action-uri       = URL "?" "action=" term
*/
//TODO action links spec
//TODO allow for multiple links per line seperated by ','
link_header:
  LINK_HEADER  link_path_attr rel_attr (self_attr | link_category_attr)* link_attributes_attr?
;

link_path_attr:
  OPEN_PATH link_path_val CLOSE_PATH
;
link_path_val:
  PATH
;

self_attr:
  CAT_ATTR_SEP SELF_ATTR VAL_ASSIGN QUOTE self_val QUOTE
;
self_val:
  TOKEN
;

link_category_attr:
  CAT_ATTR_SEP CAT_ATTR VAL_ASSIGN QUOTE link_category_val QUOTE
;
link_category_val:
  TOKEN
;

link_attributes_attr:
  (CAT_ATTR_SEP attribute_attr)+
;
attribute_attr:
  attribute_attr_name VAL_ASSIGN attribute_attr_val
;
attribute_attr_name:
  ATTRIB_NAME
;
attribute_attr_val:
  (QUOTE attribute_attr_string_val QUOTE) | attribute_attr_int_val
;
attribute_attr_string_val:
  TOKEN
;
attribute_attr_int_val:
  DIGIT
;


// ----------------------------------------
// -------- X-OCCI-Attribute Header--------
// ----------------------------------------
/*

ABNF representation of X-OCCI-Attribute from the http rendering specification

  Attribute        = "X-OCCI-Attribute" ":" #attribute-repr
  attribute-repr   = attribute-name "=" ( token | quoted-string )
  attribute-name   = attr-component *( "." attr-component )
  attr-component   = LOALPHA *( LOALPHA | DIGIT | "-" | "_" )

Example:
  X-OCCI-Attribute: occi.compute.architechture="x86_64"
  X-OCCI-Attribute: occi.compute.architechture="x86_64", occi.compute.cores=2
*/

attribute_header:
  ATTR_HEADER attribute_attrs
;
attribute_attrs:
  attribute_attr (',' attribute_attr)*
;

// ----------------------------------------
// ------- X-OCCI-Location Header ---------
// ----------------------------------------
/*

ABNF representation of X-OCCI-Location from the http rendering specification

  Location        = "X-OCCI-Location" ":" location-value
  location-value  = URI-reference

Examples:
  X-OCCI-Location: http://example.com/compute/123
  X-OCCI-Location: http://example.com/compute/123, http://example.com/compute/123
*/

location_header:
  LOCATION_HEADER location_paths
;
location_paths:
  location_path (',' location_path)*
;
location_path:
  PATH
;

//TODO many of these lexical rules need to be more accurate
ATTRIB_NAME: ('a'..'z' | 'A'..'Z')('a'..'z' | 'A'..'Z' | DIGIT)+ ('.') TOKEN;
PATH: ('/' TOKEN) ('/' TOKEN)*;
CLASS: ('kind'|'mixin'|'action');
URI: ('http://' | 'https://') TOKEN;
TOKEN: ('a'..'z' | 'A'..'Z') ('a'..'z' | 'A'..'Z')*;
DIGIT: '0'..'9'+;
WS: (' ' | '\t' | '\n' | '\r'){$channel = HIDDEN;};