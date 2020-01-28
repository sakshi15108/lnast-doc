

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
// c++


// 4 valid lnast assign_node with data of line number and position
auto node_statements = Lnast_node::create_statements("SEQ0");   
auto node_statements = Lnast_node::create_statements("SEQ0", line_num);   
auto node_statements = Lnast_node::create_statements("SEQ0", line_num, pos); 
auto node_statements = Lnast_node::create_statements(Token); 


// 3 valid lnast assign_node with data of line number and position
auto node_pure_assign = Lnast_node::create_pure_assign(line_num);   
auto node_pure_assign = Lnast_node::create_pure_assign(line_num, pos); 
auto node_pure_assign = Lnast_node::create_pure_assign(); 


// 4 valid lnast ref_node with data of string_view, line number, position or Token.
auto node_ref = Lnast_node::create_ref("val");
auto node_ref = Lnast_node::create_ref("val", line_num);
auto node_ref = Lnast_node::create_ref("val", line_num, pos);
auto node_ref = Lnast_node::create_ref(Token);


// 4 valid lnast const_node with data of string_view, line number, position or Token.
auto node_const = Lnast_node::create_const("0d1023u10"); 
auto node_const = Lnast_node::create_const("0d1023u10", line_num);
auto node_const = Lnast_node::create_const("0d1023u10", line_num, pos);
auto node_const = Lnast_node::create_const(Token);

auto idx_statements = lnast->add_child(idx_root,       node_statements);
auto idx_assign     = lnast->add_child(idx_statements, node_pure_assign);
auto idx_val        = lnast->add_child(idx_assign,     node_ref);
auto idx_const      = lnast->add_child(idx_assign,     node_const);
```

![assign](source/graphviz/assign_trivial_constant.png)

An pure_assign node sets the right hand side value to the reference pointed by the left hand side of the expression. The left hand side is always a reference. The right hand side is a reference or a constant.

## Assign Simple Expression

```coffescript
total = (x - 1) + 3 + 2
```

```shell
1       0       0       SEQ0
2       1       0       0       21      -       ___c    x       0d1
3       1       1       0       21      +       ___b    ___c    0d3
4       1       2       0       21      +       ___a    ___b    0d2
5       1       3       0       21      =       total   ___a

```

```cpp
Lnast_ntype nt_total = Lnast_type::create_ref();
Lnast_ntype nt_b     = Lnast_type::create_ref();
Lnast_ntype nt____a  = Lnast_type::create_ref();

```

```shell
1       0       SEQ0
2       1       0       13      -       ___a    b       0d1
3       1       0       13      =       total   ___a
```

```cpp
Lnast_ntype nt_total = Lnast_type::create_ref();
Lnast_ntype nt_b     = Lnast_type::create_ref();
Lnast_ntype nt____a  = Lnast_type::create_ref();

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

