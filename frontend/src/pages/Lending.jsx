import { useState } from 'react';

export default function Lending() {
  const [action, setAction] = useState('deposit');
  const [amount, setAmount] = useState('');
  const [asset, setAsset] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!amount || !asset) {
      setError('Please fill all fields');
      return;
    }

    try {
      setLoading(true);
      await new Promise(resolve => setTimeout(resolve, 1000));
      setAmount('');
      setAsset('');
    } catch (err) {
      setError(err.message || 'Transaction failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto">
      <div className="bg-gray-800 p-8 rounded-lg border border-gray-700">
        <h1 className="text-3xl font-bold mb-6">Lending & Borrowing</h1>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-semibold mb-2">Action</label>
            <select
              value={action}
              onChange={(e) => setAction(e.target.value)}
              className="w-full bg-gray-700 border border-gray-600 rounded px-4 py-2 text-white"
            >
              <option value="deposit">📥 Deposit</option>
              <option value="borrow">💰 Borrow</option>
              <option value="repay">↩️ Repay</option>
              <option value="withdraw">📤 Withdraw</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-semibold mb-2">Asset Address</label>
            <input
              type="text"
              value={asset}
              onChange={(e) => setAsset(e.target.value)}
              placeholder="0x..."
              className="w-full bg-gray-700 border border-gray-600 rounded px-4 py-2 text-white"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold mb-2">Amount</label>
            <input
              type="number"
              step="0.0001"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="0.0"
              className="w-full bg-gray-700 border border-gray-600 rounded px-4 py-2 text-white"
            />
          </div>

          {error && (
            <div className="bg-red-600 text-white p-3 rounded">❌ {error}</div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 p-3 rounded font-bold transition"
          >
            {loading ? `⏳ ${action.charAt(0).toUpperCase() + action.slice(1)}ing...` : action.charAt(0).toUpperCase() + action.slice(1)}
          </button>
        </form>
      </div>
    </div>
  );
}
