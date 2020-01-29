# Introduction
LNAST stands for Language-Neutral Abstract Syntax Tree, which is constituted of  
Lnast_nodes and indexed by a tree structure.  

Each Lnast_node should has a specific node type and contain the following information from source code tokens  
(a) line number   
(b) pos   
(c) string_view   

## Function Overloadings of Node Data Construction
Every node construction method has four function overloadings.  
For example, to construct a Lnast_node with a type of reference,  
we could use one of the following functions:  


```cpp
//C++
auto node_ref = Lnast_node::create_ref("foo");     
auto node_ref = Lnast_node::create_ref("foo", line_num);     
auto node_ref = Lnast_node::create_ref("foo", line_num, pos1, pos2);     
auto node_ref = Lnast_node::create_ref(token);   
```  

In case (1), you only knows the variable name is "foo".  
In case (2), you know the variable name and the corresponding line number.  
In case (3), you know the variable name, the line number, and the charactrer position.  
In case (4), you are building LNAST from your HDL AST and you already have the Token.   
The toke should have line number, pos, and string_view information.  


## Another Example
If you don't care the string_view to be stored in the node, just leave it empty for set "foo" for it.  
For example, to build a node with type of pure_assign.  


```cpp
//C++
auto node_pure_assign = Lnast_node::create_pure_assign();   
auto node_pure_assign = Lnast_node::create_pure_assign(line_num);     
auto node_pure_assign = Lnast_node::create_pure_assign(line_num, pos1, pos2);   
auto node_pure_assign = Lnast_node::create_pure_assign(token); // The token is not necessary to have a string_view  
```


# Assign Statement

## Assign Trivial Constant

```coffescript
// Pyrope
val = 1023u10bits
```

```verilog
// Verilog
assign val = 10`d1023
```

```shell
// CFG
1       0       0       SEQ0
2       1       0       0       10      =       val     0d1023u10
```

```cpp
// C++
auto node_statements  = Lnast_node::create_statements ("foo", line_num, pos1, pos2); 
auto node_pure_assign = Lnast_node::create_pure_assign("foo", line_num, pos1, pos2); 
auto node_target      = Lnast_node::create_ref        ("val", line_num, pos1, pos2);
auto node_const       = Lnast_node::create_const      ("0d1023u10", line_num, pos1, pos2);

auto idx_statements = lnast->add_child(idx_root,       node_statements);
auto idx_assign     = lnast->add_child(idx_statements, node_pure_assign);
auto idx_target     = lnast->add_child(idx_assign,     node_target);
auto idx_const      = lnast->add_child(idx_assign,     node_const);
```

![assign](source/graphviz/assign_trivial_constant.png)

An pure_assign node sets the right hand side value to the reference pointed by the left hand side    
of the expression. The left hand side is always a reference. The right hand side is a reference or a constant.   

## Assign Simple Expression

```coffescript
//Pyrope
total = (x - 1) + 3 + 2
```


```verilog
//Verilog
assign total = (x - 1) + 3 + 2
```


```shell
//CFG
1       0       0       SEQ0
2       1       0       0       21      -       ___a    x       0d1
3       1       1       0       21      +       ___b    ___a    0d3    0d2
4       1       3       0       21      =       total   ___b

```

```cpp
// C++

// preparing lnast_node data
// Note: as mentioned in the introduction, if you have the HDL-AST in hand, using
// Token directly instead of explicit string, line_num, pos ... etc.

auto node_sts          = Lnast_node::create_statements  ("foo",  line_num, pos1, pos2); 
node node_minus        = Lnast_node::create_minus       ("foo",  line_num, pos1, pos2);
node node_lhs1         = Lnast_node::create_ref         ("___a", line_num, pos1, pos2);
node node_op1          = Lnast_node::create_ref         ("x",    line_num, pos1, pos2);
node node_op2          = Lnast_node::create_const       ("0d1",  line_num, pos1, pos2);

node node_plus         = Lnast_node::create_plis        ("bar",  line_num, pos1, pos2);
node node_lhs2         = Lnast_node::create_ref         ("___b", line_num, pos1, pos2);
node node_op3          = Lnast_node::create_ref         ("___a", line_num, pos1, pos2);
node node_op4          = Lnast_node::create_const       ("0d3",  line_num, pos1, pos2);
node node_op5          = Lnast_node::create_const       ("0d2",  line_num, pos1, pos2);

auto node_pure_assign  = Lnast_node::create_pure_assign ("foo2",  line_num, pos1, pos2); 
auto node_lhs3         = Lnast_node::create_ref         ("total", line_num, pos1, pos2);
auto node_op6          = Lnast_node::create_ref         ("___b",  line_num, pos1, pos2);


//construct the LNAST
auto idx_sts        = lnast->add_child(idx_root,  node_sts);
auto idx_minus      = lnast->add_child(idx_sts,   node_minus);
auto idx_lhs1       = lnast->add_child(idx_minus, node_lhs1);
auto idx_op1        = lnast->add_child(idx_minus, node_op1);        
auto idx_op2        = lnast->add_child(idx_minus, node_op2);        

auto idx_plus       = lnast->add_child(idx_sts,   node_plus);
auto idx_lhs2       = lnast->add_child(idx_plus,  node_lhs2);
auto idx_op3        = lnast->add_child(idx_plus,  node_op3);        
auto idx_op4        = lnast->add_child(idx_plus,  node_op4);        
auto idx_op5        = lnast->add_child(idx_plus,  node_op5);        

auto idx_assign     = lnast->add_child(idx_sts,    node_pure_assign);
auto idx_lhs3       = lnast->add_child(idx_assign, node_lhs3);
auto idx_op6        = lnast->add_child(idx_assign, node_op6);        
```


![assign](source/graphviz/assign_simple_expression.png)

Statements that have operations must breakdown the operations per type, and then assign the temporal value to the assign node.

# if Statement

```coffescript
if a > 3 {
  a = a - 1
}
```

```cpp
Lnast_ntype nt_if    = Lnast_type::create_if();
Lnast_ntype nt_cstmt = Lnast_type::create_cstnt();

auto if_idx = lnast->add_child(parent_idx, Lnast_node(nt_if));
lnast->add_child(if_idx, Lnast_node(nt_cstat));
lnast->add_child(if_idx, Lnast_node(...));
```

```shell
1       0       SEQ0
3       2       SEQ1
4       3       0       23      >       ___a    a       0d3
6       2       SEQ2
7       6       0       23      -       ___b    a       0d1
8       6       0       23      =       a       ___b
2       1       0       23      if      ___a
```

