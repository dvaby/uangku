package finance

import (
	"encoding/json"
	"math"
	"strings"
	"testing"
)

func TestCalculateSummary(t *testing.T) {
	tests := []struct {
		name        string
		input       string
		want        summary
		wantErrText string
	}{
		{
			name:  "income only",
			input: `[{"type":"income","amount":125000}]`,
			want:  summary{IncomeTotal: 125000, NetBalance: 125000},
		},
		{
			name:  "expense only",
			input: `[{"type":"expense","amount":45000}]`,
			want:  summary{ExpenseTotal: 45000, NetBalance: -45000},
		},
		{
			name: "mixed transactions",
			input: `[
				{"type":"income","amount":100000},
				{"type":"expense","amount":25000},
				{"type":"income","amount":5000}
			]`,
			want: summary{
				IncomeTotal:  105000,
				ExpenseTotal: 25000,
				NetBalance:   80000,
			},
		},
		{
			name:  "empty transaction list",
			input: `[]`,
			want:  summary{},
		},
		{
			name:  "zero amount",
			input: `[{"type":"income","amount":0}]`,
			want:  summary{},
		},
		{
			name:        "malformed JSON",
			input:       `[`,
			wantErrText: "INVALID_ARGUMENT:",
		},
		{
			name:        "negative amount",
			input:       `[{"type":"expense","amount":-1}]`,
			wantErrText: "must not be negative",
		},
		{
			name:        "unsupported type",
			input:       `[{"type":"transfer","amount":1}]`,
			wantErrText: "unsupported type",
		},
		{
			name:        "missing amount",
			input:       `[{"type":"income"}]`,
			wantErrText: "must include type and amount",
		},
		{
			name:        "unknown field",
			input:       `[{"type":"income","amount":1,"note":"not supported"}]`,
			wantErrText: "INVALID_ARGUMENT:",
		},
		{
			name:        "non-integer amount",
			input:       `[{"type":"income","amount":1.5}]`,
			wantErrText: "INVALID_ARGUMENT:",
		},
		{
			name:        "null input",
			input:       `null`,
			wantErrText: "transactions must be a JSON array",
		},
		{
			name:        "trailing JSON value",
			input:       `[] []`,
			wantErrText: "exactly one JSON value",
		},
		{
			name:  "largest supported total",
			input: `[{"type":"income","amount":9223372036854775807}]`,
			want:  summary{IncomeTotal: math.MaxInt64, NetBalance: math.MaxInt64},
		},
		{
			name: "income total overflow",
			input: `[{"type":"income","amount":9223372036854775807},
				{"type":"income","amount":1}]`,
			wantErrText: "supported range",
		},
		{
			name:  "largest negative net balance",
			input: `[{"type":"expense","amount":9223372036854775807}]`,
			want:  summary{ExpenseTotal: math.MaxInt64, NetBalance: -math.MaxInt64},
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			gotJSON, err := CalculateSummary(test.input)
			if test.wantErrText != "" {
				if err == nil || !strings.Contains(err.Error(), test.wantErrText) {
					t.Fatalf("CalculateSummary() error = %v, want text %q", err, test.wantErrText)
				}
				if gotJSON != "" {
					t.Fatalf("CalculateSummary() JSON = %q on error, want empty", gotJSON)
				}
				return
			}
			if err != nil {
				t.Fatalf("CalculateSummary() error = %v", err)
			}

			var got summary
			if err := json.Unmarshal([]byte(gotJSON), &got); err != nil {
				t.Fatalf("decode summary %q: %v", gotJSON, err)
			}
			if got != test.want {
				t.Fatalf("CalculateSummary() = %+v, want %+v", got, test.want)
			}
		})
	}
}
