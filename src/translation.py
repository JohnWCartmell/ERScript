#
# Change History
#
# CR-17022 - Support three different xml representations of attributes: Attribute,Element,Anonymous.
#

class TranslationLayer(object):
    pass


class TranslationNode(object):
    ''' The process of translating between an ER model and its pysical representation
        is effected by a translation tree. This is a tree of translation nodes.
        Each node presents a uniform interface that is appropriate to the process
        of translating an ER model.
        
        Each translation node is a thin wrapper around calls to a translation layer
        object. This provides two facilities:
        
        * It makes the translation layer more straightforward to define and use.
        * It documents the operations that the translation layer must support. '''
    __slots__ = 'host', 'node'
    
    def __init__(self, host, node):
        ''' Create a node in the translation tree.
        
            host -- The translation layer in use.
            node -- The node in the data that this translation node is acting upon. '''
        self.host = host
        self.node = node
    
    def has_attribute(self, name, cfg):
        ''' Determine whether attribute exists on the node.
        
            name -- The name of the attribute. '''
        return self.host.has_attribute(self.node, name, cfg)
    
    def get_attribute(self, name, cfg):
        ''' Get the value of an attribute.
        
            name -- The name of the attribute.
            cfg  -- The attribute's configuration. A triple of (anonymous, optional,
                    enum_values). '''
        return self.host.get_attribute(self.node, name, cfg)
    
    def set_attribute(self, name, value, cfg):
        ''' Set the value of an attribute.
        
            name  -- The name of the attribute.
            value -- The value of the attribute.
            cfg   -- The attribute's configuration. A triple of (anonymous, optional,
                     enum_values). '''
        self.host.set_attribute(self.node, name, value, cfg)
    
    def get_union_case(self):
        ''' Get the concrete type of the node if it is a discriminated union. '''
        case, node = self.host.get_union_case(self.node)
        return case, TranslationNode(self.host, node)
    
    def get_child(self, relationship_name, entity_name, union_tags):
        ''' Get a child entity if the cardinality is ExactlyOne or ZeroOrOne.
        
            relationship_name -- The name of the relationship, or None if the
                                 relationship is anonymous.
            entity_name       -- The name of the entity. If the entity is a
                                 union type, then this should be the root type.
            union_tags        -- The names of the tags if this is a union type. '''
        child = self.host.get_child(self.node, relationship_name, entity_name, union_tags)
        if child is not None:
            return TranslationNode(self.host, child)
    
    def get_children(self, relationship_name, entity_name, union_tags):
        ''' Get a set of child entities if the cardinality is OneOrMore or ZeroOneOrMore.
        
            relationship_name -- The name of the relationship, or None if the
                                 relationship is anonymous.
            entity_name       -- The name of the entity. If the entity is a
                                 union type, then this should be the root type.
            union_tags        -- The names and config of the tags if this is a union type. '''
        return [TranslationNode(self.host, n)
                for n in self.host.get_children(self.node, relationship_name, entity_name, union_tags)]
    
    def factory(self, relationship_name, entity_name, multiplex):
        factory_method = self.host.attach_child
        if multiplex:
            factory_method = self.host.append_child
        return lambda union_case, cfg: TranslationNode(self.host, factory_method(self.node, relationship_name, 
                                                                                 entity_name, union_case, cfg))


class XMLData(TranslationLayer):
    def __init__(self, document):
        self.document = document

    def _get_body_text(self, node):
        return "".join(child.nodeValue for child in node.childNodes
                       if child.nodeType == child.TEXT_NODE)

    def _set_body_text(self, node, value):
        while node.childNodes:
            node.removeChild(node.childNodes[0]).unlink()
        node.appendChild(self.document.createTextNode(value))

    def _child_by_tag_cfg(self, node, *tags):
        result = []
        for n in node.childNodes:
            for tag, cfg in tags:
                if ((cfg[0] == "Anonymous" and n.nodeType == n.TEXT_NODE)  
                or  (cfg[0] == "Element" and n.nodeType == n.ELEMENT_NODE and n.tagName == tag)):
                    result.append(n)
                    break 
        return result

    def _child_by_tag(self, node, tag):
        return self._child_by_tag_cfg(node, (tag, ("Element",)))

    def has_attribute(self, node, name, cfg):
        if cfg[0]=='Element':                      
            return len(self._child_by_tag(node, name)) != 0
        elif  cfg[0]=='Attribute':
           return node.hasAttribute(name)
        elif  cfg[0]=='Anonymous':
           return True
    
    def get_attribute(self, node, name, cfg):
        if cfg[0]=='Element':
           return self._get_body_text(self._child_by_tag(node, name)[0])
        elif  cfg[0]=='Attribute':
           return node.getAttribute(name)
        elif  cfg[0]=='Anonymous':
           # If entity was also Anonymous
           if node.nodeType == node.TEXT_NODE:
               return node.nodeValue
           return self._get_body_text(node)
 
    def get_union_case(self, node):
        if node.nodeType == node.TEXT_NODE:
            return None, node
        return node.tagName, node
    
    def get_child(self, node, relationship_name, entity_name, union_tags):
        nodes = self.get_child_nodes(node, relationship_name, entity_name, union_tags)
        if len(nodes) == 0:
            return None
        if len(nodes) > 1:
            raise Exception('More than one node found, expecting zero or one')
        return nodes[0]
    
    def get_children(self, node, relationship_name, entity_name, union_tags):
        return self.get_child_nodes(node, relationship_name, entity_name, union_tags)
    
    def set_attribute(self, node, name, value, cfg):
        value_str = unicode(value)
        if isinstance(value, bool):
            value_str = value_str.lower()
        if cfg[0]=='Element':                      
            existing = self._child_by_tag(node, name)
            if len(existing) != 0:
                element = existing[0]
            else:
                element = self.document.createElement(name)
                node.appendChild(element)
            self._set_body_text(element, value_str)
        elif cfg[0]=='Attribute':
            node.setAttribute(name, value_str)
        elif cfg[0]=='Anonymous':
            # Entity is also Anonymous
            if node.nodeType == node.TEXT_NODE:
                node.nodeValue = value_str
            else:
                self._set_body_text(node, value_str)
    
    def attach_child(self, node, relationship_name, entity_name, union_case, cfg):
        return self.add_child_node(node, relationship_name, entity_name, union_case, cfg)
    
    def append_child(self, node, relationship_name, entity_name, union_case, cfg):
        return self.add_child_node(node, relationship_name, entity_name, union_case, cfg)
    
    def get_child_nodes(self, node, relationship_name, entity_name, union_tags):
        if relationship_name is not None:
            rel = self._child_by_tag(node, relationship_name)
            if len(rel) == 0:
                return ()
            node = rel[0]
        if union_tags is not None:
            return self._child_by_tag_cfg(node, *union_tags)
        return self._child_by_tag(node, entity_name)
    
    def add_child_node(self, node, relationship_name, entity_name, union_case, cfg):
        if relationship_name is not None:
            rel = self._child_by_tag(node, relationship_name)
            if len(rel) != 0:
                parent = rel[0]
            else:
                parent = self.document.createElement(relationship_name)
                node.appendChild(parent)
        else:
            parent = node
        if cfg[0] == "Anonymous":
            element = self.document.createTextNode("")
        else:
            element = self.document.createElement(union_case or entity_name)
        parent.appendChild(element)
        return element


class ProtobufData(TranslationLayer):
    def get_attribute(self, node, name, cfg):
        anonymous, optional, enum_values = cfg
        attr = getattr(node, name)
        if isinstance(attr, bool):
            attr = str(attr).lower()
        if enum_values:
            attr = enum_values[attr]
        return attr
    
    def set_attribute(self, node, name, value, cfg):
        anonymous, optional, enum_values = cfg
        if enum_values:
            value = enum_values.index(value)
        setattr(node, name, value)
    
    def has_attribute(self, node, name,cfg):
        return node.HasField(name)
    
    def get_union_case(self, node):
        name = node.DESCRIPTOR.fields[node._SUM_TYPE_].name
        return name, getattr(node, name)
    
    def get_child(self, node, relationship_name, entity_name, union_tags):
        name = relationship_name or entity_name
        if node.HasField(name):
            return getattr(node, name)
        return None
    
    def get_children(self, node, relationship_name, entity_name, union_tags):
        return getattr(node, relationship_name or entity_name)
    
    def attach_child(self, node, relationship_name, entity_name, union_case, cfg):
        child = getattr(node, relationship_name or entity_name)
        if union_case is not None and union_case != entity_name:
            child._SUM_TYPE_ = [f.name for f in child.DESCRIPTOR.fields].index(union_case)
            child = getattr(child, union_case)
        child.SetInParent()
        return child
    
    def append_child(self, node, relationship_name, entity_name, union_case, cfg):
        child = getattr(node, relationship_name or entity_name).add()
        if union_case is not None and union_case != entity_name:
            child._SUM_TYPE_ = [f.name for f in child.DESCRIPTOR.fields].index(union_case)
            child = getattr(child, union_case)
        child.SetInParent()
        return child
