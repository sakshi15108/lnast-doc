# Introduction
LNAST stands for Language-Neutral Abstract Syntax Tree, which is constituted of  
Lnast_nodes and indexed by a tree structure.  

Each Lnast_node should has a specific node type and contain the following information from source code tokens  
(a) line number   
(b) pos_start, pos_end  
(c) string_view   

## Function Overloadings of Node Data Construction
Every node construction method has four function overloadings.  
For example, to construct a Lnast_node with a type of reference,  
we could use one of the following functions:  


```cpp
// C++
auto node_ref = Lnast_node::create_ref("foo");     
auto node_ref = Lnast_node::create_ref("foo", line_num);     
auto node_ref = Lnast_node::create_ref("foo", line_num, pos1, pos2);     
auto node_ref = Lnast_node::create_ref(token);   
```  

In case (1), you only knows the variable name is "foo".  
In case (2), you know the variable name and the corresponding line number.  
In case (3), you know the variable name, the line number, and the charactrer position.  
In case (4), you are building LNAST from your HDL AST and you already have the Token.   
The toke should have line_number, positions, and string_view information.  


## Another Example
If you don't care the string_view to be stored in the node, just leave it empty for set "foo" for it.
This is true for many of the operator node, for example, to build a node with type of assign.  


```cpp
// C++
auto node_assign = Lnast_node::create_assign();   
auto node_assign = Lnast_node::create_assign(line_num);     
auto node_assign = Lnast_node::create_assign(line_num, pos1, pos2);   
auto node_assign = Lnast_node::create_assign(token); // The token is not necessary to have a string_view  
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
auto node_stmts  = Lnast_node::create_stmts  ("foo", line_num, pos1, pos2); 
auto node_assign = Lnast_node::create_assign ("foo", line_num, pos1, pos2); 
auto node_target = Lnast_node::create_ref    ("val", line_num, pos1, pos2);
auto node_const  = Lnast_node::create_const  ("0d1023u10", line_num, pos1, pos2);

auto idx_stmts  = lnast->add_child(idx_root,   node_stmts);
auto idx_assign = lnast->add_child(idx_stmts,  node_assign);
auto idx_target = lnast->add_child(idx_assign, node_target);
auto idx_const  = lnast->add_child(idx_assign, node_const);
```

![assign](source/graphviz/assign_trivial_constant.png)

An assign node sets the right hand side value to the reference pointed by the left hand side    
of the expression. The left hand side is always a reference. The right hand side is a reference or a constant.   

## Assign Simple Expression

```coffescript
// Pyrope
total = (x - 1) + 3 + 2
```


```verilog
// Verilog
assign total = (x - 1) + 3 + 2
```


```shell
// CFG
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

auto node_stmts  = Lnast_node::create_stmts  ("foo",  line_num, pos1, pos2); 
node node_minus  = Lnast_node::create_minus  ("foo",  line_num, pos1, pos2);
node node_lhs1   = Lnast_node::create_ref    ("___a", line_num, pos1, pos2);
node node_op1    = Lnast_node::create_ref    ("x",    line_num, pos1, pos2);
node node_op2    = Lnast_node::create_const  ("0d1",  line_num, pos1, pos2);

node node_plus   = Lnast_node::create_plis   ("bar",  line_num, pos1, pos2);
node node_lhs2   = Lnast_node::create_ref    ("___b", line_num, pos1, pos2);
node node_op3    = Lnast_node::create_ref    ("___a", line_num, pos1, pos2);
node node_op4    = Lnast_node::create_const  ("0d3",  line_num, pos1, pos2);
node node_op5    = Lnast_node::create_const  ("0d2",  line_num, pos1, pos2);

auto node_assign = Lnast_node::create_assign ("foo2",  line_num, pos1, pos2); 
auto node_lhs3   = Lnast_node::create_ref    ("total", line_num, pos1, pos2);
auto node_op6    = Lnast_node::create_ref    ("___b",  line_num, pos1, pos2);


// construct the LNAST
auto idx_stmts   = lnast->add_child(idx_root,  node_stmts);
auto idx_minus   = lnast->add_child(idx_stmts, node_minus);
auto idx_lhs1    = lnast->add_child(idx_minus, node_lhs1);
auto idx_op1     = lnast->add_child(idx_minus, node_op1);        
auto idx_op2     = lnast->add_child(idx_minus, node_op2);        

auto idx_plus    = lnast->add_child(idx_stmts, node_plus);
auto idx_lhs2    = lnast->add_child(idx_plus,  node_lhs2);
auto idx_op3     = lnast->add_child(idx_plus,  node_op3);        
auto idx_op4     = lnast->add_child(idx_plus,  node_op4);        
auto idx_op5     = lnast->add_child(idx_plus,  node_op5);        

auto idx_assign  = lnast->add_child(idx_stmts,  node_assign);
auto idx_lhs3    = lnast->add_child(idx_assign, node_lhs3);
auto idx_op6     = lnast->add_child(idx_assign, node_op6);        
```


![assign](source/graphviz/assign_simple_expression.png)

statements that have operations must breakdown the operations per type, and then assign the temporal value to the assign node.

# if Statement
## simple case
```coffescript
if a > 3 {
  b = a + 1
} 
```

```shell
// CFG
1  0  0  SEQ0                      
2  1  0  0     24  if  ___a        
3  2  0  SEQ1                      
4  3  0  0     24  >   ___a  a     0d3
6  2  0  SEQ2                      
7  6  0  0     24  +   ___b  a     0d1
8  6  1  0     24  =   a     ___b  
```

```verilog
assign b = (a > 3) ? a - 1 : b; //FIXME: SH: incomplete cases? combinational loop!?
```


```cpp
//C++ 

auto idx_stmts0 = lnast->add_child(idx_root,   Lnast_node::create_stmts (token_0)); 
auto idx_if     = lnast->add_child(idx_stmts0, Lnast_node::create_if    (token_1)); 

auto idx_cstmts = lnast->add_child(idx_if,     Lnast_node::create_cstmts(token_2)); 
auto idx_gt     = lnast->add_child(idx_cstmts, Lnast_node::create_gt    (token_3)); 
auto idx_lhs    = lnast->add_child(idx_gt,     LNast_node::create_ref   (token_4)); //string_view = "___a"
auto idx_op1    = lnast->add_child(idx_gt,     LNast_node::create_ref   (token_5)); //string_view = "a"
auto idx_op2    = lnast->add_child(idx_gt,     LNast_node::create_const (token_6)); //string_view = "0d3"

auto idx_stmts1 = lnast->add_child(idx_if,     Lnast_node::create_stmts (token_7));
auto idx_plus   = lnast->add_child(idx_stmts1, Lnast_node::create_plus  (token_8));
auto idx_lhs    = lnast->add_child(idx_plus,   LNast_node::create_ref   (token_9)); //string_view = "___b"
auto idx_op3    = lnast->add_child(idx_plus,   LNast_node::create_ref   (token_a)); //string_view = "a"
auto idx_op4    = lnast->add_child(idx_plus,   LNast_node::create_const (token_b)); //string_view = "0d1"

auto idx_assign = lnast->add_child(idx_stmts1, Lnast_node::create_assign(token_c)); 
auto idx_lhs    = lnast->add_child(idx_assign, LNast_node::create_ref   (token_d)); //string_view = "a"
auto idx_op5    = lnast->add_child(idx_assign, LNast_node::create_ref   (token_e)); //string_view = "___b"

```

![assign](source/graphviz/simple_if.png)
An if-subtree consisted of conditional-statements nodes and statements nodes in
the following order: cstmts1 -> stmts1 -> cstmts2 -> stmts2 ...-> stmtsN, 
if there is a final "else" chunk, it won't comes with a corresponding conditionial
statements, see the figure for illustration.


## full case
```coffescript
// Pyrope
if a > 10 {
  b = 3 
} elif a < 1 {
  b = 2
} else {
  b = 1
}
```

```verilog
// Verilog

assign b = (a > 10) ? 3 :
           (a < 1 ) ? 2 : 1 ;

```


```shell
// CFG 
1   0   0  SEQ0                       
2   1   0  0     62  if    ___a       
3   2   0  SEQ1                       
4   3   0  0     62  >     ___a  a    0d10
6   2   0  SEQ2                       
7   6   0  0     62  =     b     0d3  
9   2   2  0     62  elif  ___b       
10  2   0  SEQ3                       
11  10  0  0     62  <     ___b  a    0d1
13  2   0  SEQ4                       
14  13  0  0     62  =     b     0d2  
16  2   0  SEQ5                       
17  16  0  0     62  =     b     0d1  
```


```cpp
//C++ 

auto idx_stmts0  = lnast->add_child(idx_root,   Lnast_node::create_stmts (token_0));
auto idx_if      = lnast->add_child(idx_stmts0, Lnast_node::create_if    (token_1));

auto idx_cstmts1 = lnast->add_child(idx_if,     Lnast_node::create_cstmts(token_2));
auto idx_gt      = lnast->add_child(idx_cstmts, Lnast_node::create_gt    (token_3)); 
auto idx_lhs     = lnast->add_child(idx_gt,     LNast_node::create_ref   (token_4)); //string_view = "___a"
auto idx_op1     = lnast->add_child(idx_gt,     LNast_node::create_ref   (token_5)); //string_view = "a"
auto idx_op2     = lnast->add_child(idx_gt,     LNast_node::create_const (token_6)); //string_view = "0d10"

auto idx_stmts1  = lnast->add_child(idx_if,     Lnast_node::create_stmts (token_7));
auto idx_assign  = lnast->add_child(idx_stmts1, Lnast_node::create_assign(token_8));
auto idx_lhs     = lnast->add_child(idx_assign, LNast_node::create_ref   (token_9)); //string_view = "b"
auto idx_op1     = lnast->add_child(idx_assign, LNast_node::create_const (token_a)); //string_view = "0d3"

auto idx_cstmts2 = lnast->add_child(idx_if,     Lnast_node::create_cstmts(token_b));
auto idx_lt      = lnast->add_child(idx_cstmts, Lnast_node::create_lt    (token_c)); 
auto idx_lhs     = lnast->add_child(idx_lt,     LNast_node::create_ref   (token_d)); //string_view = "___b"
auto idx_op1     = lnast->add_child(idx_lt,     LNast_node::create_ref   (token_e)); //string_view = "a"
auto idx_op2     = lnast->add_child(idx_lt,     LNast_node::create_const (token_f)); //string_view = "0d1"

auto idx_stmts2  = lnast->add_child(idx_if,     Lnast_node::create_stmts (token_g));
auto idx_assign  = lnast->add_child(idx_stmts2, Lnast_node::create_assign(token_h));
auto idx_lhs     = lnast->add_child(idx_assign, LNast_node::create_ref   (token_i)); //string_view = "b"
auto idx_op1     = lnast->add_child(idx_assign, LNast_node::create_const (token_j)); //string_view = "0d2"
    
auto idx_stmts3  = lnast->add_child(idx_if,     Lnast_node::create_stmts (token_k));
auto idx_assign  = lnast->add_child(idx_stmts3, Lnast_node::create_assign(token_l));
auto idx_lhs     = lnast->add_child(idx_assign, LNast_node::create_ref   (token_m)); //string_view = "b"
auto idx_op1     = lnast->add_child(idx_assign, LNast_node::create_const (token_n)); //string_view = "0d3"

```

![assign](source/graphviz/full_case_if.png)
