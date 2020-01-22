

# Assign Statements

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
Lnast_ntype nt_val   = Lnast_type::create_ref();
Lnast_ntype nt_const = Lnast_type::create_const();
Lnast_ntype nt_assign = Lnast_type::create_assign();

auto idx_assign = lnast->add_child(idx_parent, Lnast_node(nt_assign));
auto idx_val    = lnast->add_child(idx_assign, Lnast_node(nt_val, Token(Token_id_alnum, 0, 0, "val")));
auto idx_const  = lnast->add_child(idx_assign, Lnast_node(nt_const, Token(Token_id_num, 7, 0, "0d1023u10")));

Lnast_ntype nt_val   = Lnast_type::create_ref();
Lnast_ntype nt_const = Lnast_type::create_const();
Lnast_ntype nt_assign = Lnast_type::create_assign();


auto lnast_val = Lnast_node::create_ref("val");
auto lnast_val = Lnast_node::create_ref("val", LineNo);
auto lnast_val = Lnast_node::create_ref("val", LineNo, Pos);
auto lnast_val = Lnast_node::create_ref(Token);

auto lnast_val = Lnast_node::create_const("0d1023u10");

auto lnast_assign = Lnast_node::create_assign(0); // 0 line number

auto idx_assign = lnast->add_child(idx_parent, lnast_assign);
auto idx_val    = lnast->add_child(idx_assign, lnast_val);
auto idx_const  = lnast->add_child(idx_assign, lnast_const);
```

![assign](source/graphviz/assign_trivial_constant.png)

An assignment node sets the right hand side value to the reference pointed by the left hand side of the expression.
The left hand side is always a reference. The right hand side is a reference or a constant.

## Assign Simple Expression

```coffescript
total = (x - 1) + 3 + 2
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

auto if_idx = lnast->add_child(parent_idx, Lnast_node(nt_if));
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

auto if_idx = lnast->add_child(parent_idx, Lnast_node(nt_if));
```

![assign](source/graphviz/assign_simple_expression.png)

Statements that have operations must breakdown the operations per type, and then assign the temporal value to the assign node.

# if Statements

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

