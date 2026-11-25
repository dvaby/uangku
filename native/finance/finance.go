package finance

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math"
	"strings"
)

type transaction struct {
	Type   *string `json:"type"`
	Amount *int64  `json:"amount"`
}

type summary struct {
	IncomeTotal  int64 `json:"incomeTotal"`
	ExpenseTotal int64 `json:"expenseTotal"`
	NetBalance   int64 `json:"netBalance"`
}

// CalculateSummary calculates income, expense, and net balance from JSON
// transactions whose amounts are non-negative whole rupiah values.
func CalculateSummary(transactionsJSON string) (string, error) {
	transactions, err := decodeTransactions(transactionsJSON)
	if err != nil {
		return "", err
	}

	result := summary{}
	for index, item := range transactions {
		if item.Type == nil || item.Amount == nil {
			return "", invalidInput("transaction %d must include type and amount", index)
		}
		if *item.Amount < 0 {
			return "", invalidInput("transaction %d amount must not be negative", index)
		}

		var total *int64
		switch *item.Type {
		case "income":
			total = &result.IncomeTotal
		case "expense":
			total = &result.ExpenseTotal
		default:
			return "", invalidInput("transaction %d has an unsupported type", index)
		}

		if *total > math.MaxInt64-*item.Amount {
			return "", invalidInput("transaction totals exceed the supported range")
		}
		*total += *item.Amount
	}

	if result.IncomeTotal >= result.ExpenseTotal {
		result.NetBalance = result.IncomeTotal - result.ExpenseTotal
	} else {
		result.NetBalance = -(result.ExpenseTotal - result.IncomeTotal)
	}

	encoded, err := json.Marshal(result)
	if err != nil {
		return "", fmt.Errorf("encode summary: %w", err)
	}
	return string(encoded), nil
}

func decodeTransactions(input string) ([]transaction, error) {
	decoder := json.NewDecoder(strings.NewReader(input))
	decoder.DisallowUnknownFields()

	var transactions []transaction
	if err := decoder.Decode(&transactions); err != nil {
		return nil, invalidInput("transactions must be a JSON array")
	}
	if transactions == nil {
		return nil, invalidInput("transactions must be a JSON array")
	}

	var trailing any
	if err := decoder.Decode(&trailing); !errors.Is(err, io.EOF) {
		return nil, invalidInput("transactions must contain exactly one JSON value")
	}
	return transactions, nil
}

func invalidInput(format string, args ...any) error {
	return fmt.Errorf("INVALID_ARGUMENT: "+format, args...)
}
