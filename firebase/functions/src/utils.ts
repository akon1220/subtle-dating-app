const numericOperators = new Set(["<", ">", ">=", "<=", "=", "!="]);
const stringOperators = new Set(["=", "!="]);

const numericFields = new Set(["birthday", "creationDate"]);
const stringFields = new Set(["location", "name", "university"]);

interface ValidationResult {
  valid : boolean,
  message: string
}

/**
 * validates filter queries
 * @param {string[]} fields a list of fields to filter by
 * @param {string[]} operators a list of operators for each field
 * @param {string[]} values a list of values for each field
 * @return {ValdiationResult} result of checking each filter
 */
function validateFilters(fields: string[],
    operators: string[],
    values: string[]) : ValidationResult {
  if (typeof fields == "undefined" ||
      typeof operators == "undefined" ||
      typeof values == "undefined") {
    return {
      valid: true,
      message: "There are no filters",
    };
  }
  const f = fields.length;
  const o = operators.length;
  const v = values.length;
  if (f !== o || o !== v || f !== v) {
    return {
      valid: false,
      message: "The number of fields, operators, and values do not match",
    };
  }

  for (let i = 0; i < f; i++) {
    if (! validateSingleFilter(fields[i], operators[i], values[i])) {
      return {
        valid: false,
        message: `${fields[i]} ${operators[i]} ${values[i]} is not valid`,
      };
    }
  }

  return {
    valid: true,
    message: "valid filter combinations",
  };
}

/**
 * validates a single filter query
 * @param {string[]} field the field to filter by
 * @param {string[]} operator the operator for the field
 * @param {string[]} value the value for the operator
 * @return {boolean} whether a single filter is valid
 */
function validateSingleFilter(field: string,
    operator: string,
    value: string) : boolean {
  if (numericFields.has(field)) {
    return numericOperators.has(operator) && !isNaN(Number(value));
  }
  if (stringFields.has(field)) {
    return stringOperators.has(operator);
  }
  return false;
}

/**
 * construct a single query for the filters joined with AND
 * if the same fields appear multiple times, they are joined with OR
 * @param {string[]} fields a list of fields to filter by
 * @param {string[]} operators a list of operators for each field
 * @param {string[]} values a list of values for each field
 * @return {string} the complete query
 */
function constructQuery(fields: string[],
    operators: string[],
    values: string[]) : string {
  if (typeof fields == "undefined" ||
        typeof operators == "undefined" ||
        typeof values == "undefined") {
    return "";
  }
  const numericQueries : string[] = [];
  // For using OR operator for the same string field
  const stringQueryMap = new Map<string, string>();
  for (let i = 0; i<fields.length; i++) {
    const query = constructSingleQuery(fields[i], operators[i], values[i]);
    if (numericFields.has(fields[i])) {
      numericQueries.push(query);
    }
    if (stringFields.has(fields[i])) {
      if (stringQueryMap.has(fields[i])) {
        const prevQuery = stringQueryMap.get(fields[i]) || "";
        const newQuery = `${prevQuery} OR ${query}`;
        stringQueryMap.set(fields[i], newQuery);
      } else {
        stringQueryMap.set(fields[i], query);
      }
    }
  }
  const callback = (previousValue: string, currentValue: string) => {
    return `${previousValue} AND (${currentValue})`;
  };
  const stringQueries = Array.from(stringQueryMap.values());
  let finalQuery = "";
  if (numericQueries.length > 0) {
    finalQuery = numericQueries.reduce(callback);
  }
  if (stringQueries.length > 0 ) {
    if (finalQuery == "") {
      finalQuery = stringQueries.reduce(callback);
    } else {
      finalQuery = stringQueries.reduce(callback, finalQuery);
    }
  }
  return finalQuery;
}

/**
 * construct a single query filter
 * @param {string} field the field to filter by
 * @param {string} operator the operator for the field
 * @param {string} value the value for the field
 * @return {string} the singular query
 */
function constructSingleQuery(field: string,
    operator: string,
    value: string) : string {
  if (numericFields.has(field)) {
    if (field === "birthday") {
      return `birthdayTimestamp ${operator} ${value}`;
    }
    if (field === "creationDate") {
      return `creationTimestamp ${operator} ${value}`;
    }
    return `${field} ${operator} ${value}`;
  }
  if (stringFields.has(field)) {
    if (operator == "=") {
      return `${field}:"${value}"`;
    } else if (operator == "!=") {
      return `NOT ${field}:"${value}"`;
    }
  }
  return "";
}

export {validateFilters, constructQuery};
