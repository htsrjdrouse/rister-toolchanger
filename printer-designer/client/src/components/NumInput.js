import React, { useState } from 'react';

// Numeric input that allows free typing without snapping to fallback values.
// Stores raw string locally while focused, commits parsed number on blur.
export default function NumInput({ value, onChange, fallback = 0, integer = false, ...props }) {
  const [local, setLocal] = useState(null);
  const display = local !== null ? local : value;
  return (
    <input
      {...props}
      type="number"
      value={display}
      onChange={(e) => setLocal(e.target.value)}
      onFocus={(e) => setLocal(e.target.value)}
      onBlur={(e) => {
        const num = integer ? parseInt(e.target.value) : parseFloat(e.target.value);
        onChange(isNaN(num) ? fallback : num);
        setLocal(null);
      }}
    />
  );
}
