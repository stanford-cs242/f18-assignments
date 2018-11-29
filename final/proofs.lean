-- Required: chapters 1, 2, 3
section part1
  variables p q r s : Prop

  theorem and_commutativity : p ∧ q ↔ q ∧ p :=
    sorry

  theorem demorgans_law : ¬(p ∨ q) ↔ ¬p ∧ ¬q :=
    sorry

  theorem contraposition : (p → q) → (¬q → ¬p) :=
    sorry
end part1

-- Required: chapters 1, 2, 3, 4.1
section part2
  variables (α : Type) (p q : α → Prop)
  variable r : Prop

  theorem and_forall_dist : (∀ x, p x ∧ q x) ↔ (∀ x, p x) ∧ (∀ x, q x) :=
    sorry

  theorem unbound_prop : (∀ x, p x ∨ r) ↔ (∀ x, p x) ∨ r :=
    sorry

  variables (men : Type) (barber : men)
  variable  (shaves : men → men → Prop)

  theorem barber_paradox : ¬ (∀ x : men, shaves barber x ↔ ¬ shaves x x) :=
    sorry
end part2

-- Required: chapters 1, 2, 3, 4.1, 4.4
section part4
  open classical

  variables (α : Type) (p q : α → Prop)
  variable a : α
  variable r : Prop

  theorem forall_inverse : (∀ x, p x) ↔ ¬ (∃ x, ¬ p x) :=
    sorry
end part4

-- Required: chapters 1, 2, 3, 4
section part5
  variables (real : Type) [ordered_ring real]
  variables (log exp : real → real)
  variable  log_exp_eq : ∀ x, log (exp x) = x
  variable  exp_log_eq : ∀ {x}, x > 0 → exp (log x) = x
  variable  exp_pos    : ∀ x, exp x > 0
  variable  exp_add    : ∀ x y, exp (x + y) = exp x * exp y

  -- this ensures the assumptions are available in tactic proofs
  include log_exp_eq exp_log_eq exp_pos exp_add

  example (x y z : real) :
    exp (x + y + z) = exp x * exp y * exp z :=
  by rw [exp_add, exp_add]

  example (y : real) (h : y > 0)  : exp (log y) = y :=
    exp_log_eq h

  theorem log_mul {x y : real} (hx : x > 0) (hy : y > 0) :
    log (x * y) = log x + log y :=
    sorry
end part5

-- Required: chapters 1, 2, 3, 4, 7
section part6
  inductive Typ
  | Nat
  | Fun : Typ → Typ → Typ

  inductive Expr
  | Nat : ℕ → Expr
  | Add : Expr → Expr → Expr
  | Lam : Typ → Expr → Expr
  | App : Expr -> Expr -> Expr
  | Var : ℕ → Expr

  def ProofContext := list Typ

  variable has_type : ProofContext → Expr → Typ → Prop

  variable t_nat : ∀ (gamma : ProofContext), ∀ (n : ℕ),
    has_type gamma (Expr.Nat n) Typ.Nat

  variable t_add : ∀ (gamma : ProofContext), ∀ (e1 : Expr), ∀ (e2 : Expr),
    (has_type gamma e1 Typ.Nat) ∧ (has_type gamma e2 Typ.Nat) →
      has_type gamma (Expr.Add e1 e2) Typ.Nat

  variable t_lam : ∀ (gamma : ProofContext), ∀ (e : Expr), ∀ (t_arg : Typ), ∀ (t_ret : Typ),
    has_type (t_arg :: gamma) e t_ret →
      has_type gamma (Expr.Lam t_arg e) (Typ.Fun t_arg t_ret)

  variable t_app : ∀ (gamma : ProofContext), ∀ (e1 : Expr), ∀ (e2 : Expr), ∀ (t_arg : Typ), ∀ (t_ret : Typ),
    has_type gamma e1 (Typ.Fun t_arg t_ret) ∧ has_type gamma e2 t_arg →
      has_type gamma (Expr.App e1 e2) t_ret

  variable t_var : ∀ (gamma : ProofContext), ∀ (t : Typ), ∀ (n : ℕ),
    gamma.nth n = some t → has_type gamma (Expr.Var n) t

  def e1 : Expr := (Expr.Add (Expr.Nat 3) (Expr.Nat 2))
  theorem e1_type : has_type [] e1 Typ.Nat :=
    sorry

  def e2 : Expr := Expr.Lam Typ.Nat (Expr.Var 0)
  theorem e2_type : has_type [] e2 (Typ.Fun Typ.Nat Typ.Nat) :=
    sorry
end part6
