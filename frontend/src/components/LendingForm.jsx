import { useState } from 'react';
import { ethers } from 'ethers';
import { useWalletContext } from '../context/WalletContext';
import { getAddresses } from '../config/addresses';
import LendingPoolABI from '../abi/LendingPool.json';

export default function LendingForm() {
  const [action, setAction] = useState('deposit');
  const [amount, setAmount] = useState('');
  const [asset, setAsset] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [txHash, setTxHash] = useState('');
  
  const { isConnected, chainId, provider } = useWalletContext();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setTxHash('');

    if (!isConnected) {
      setError('Please connect wallet');
      return;
    }

    if (!amount || !asset) {
      setError('Please fill all fields');
      return;
    }

    try {
      setLoading(true);

      const addresses = getAddresses(chainId);
      const signer = provider.getSigner();

      const lendingPool = new ethers.Contract(
        addresses.lendingPool,
        LendingPoolABI.abi,
        signer
      );

      const amountWei = ethers.utils.parseEther(amount);
      
      let tx;
      if (action === 'deposit') {
        tx = await lendingPool.deposit(asset, amountWei);
      } else if (action === 'borrow') {
        tx = await lendingPool.borrow(asset, amountWei);
      } else if (action === 'repay') {
        tx = await lendingPool.repay(asset, amountWei);
      } else if (action === 'withdraw') {
        tx = await lendingPool.withdraw(asset, amountWei);
      }

      setTxHash(tx.hash);
      await tx.wait();

      setSuccess(`${action.charAt(0).toUpperCase() + action.slice(1)} successful!`);
      setAmount('');
      setAsset('');
    } catch (err) {
      console.error('Transaction error:', err);
      setError(err.reason || err.message || 'Transaction failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-semibold mb-2">Action</label>
        <select
          value={action}
          onChange={(e) => setAction(e.target.value)}
          className="w-full bg-gray-700 border border-gray-600 rounded px-4 py-2 text-white focus:border-blue-500 focus:outline-none transition"
        >
          <option value="deposit">Deposit</option>
          <option value="borrow">Borrow</option>
          <option value="repay">Repay</option>
          <option value="withdraw">Withdraw</option>
        </select>
      </div>

      <div>
        <label className="block text-sm font-semibold mb-2">Asset Address</label>
        <input
          type="text"
          value={asset}
          onChange={(e) => setAsset(e.target.value)}
          placeholder="0x..."
          className="w-full bg-gray-700 border border-gray-600 rounded px-4 py-2 text-white placeholder-gray-500 focus:border-blue-500 focus:outline-none transition"
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
          className="w-full bg-gray-700 border border-gray-600 rounded px-4 py-2 text-white placeholder-gray-500 focus:border-blue-500 focus:outline-none transition"
        />
      </div>

      {error && (
        <div className="bg-red-600 text-white p-3 rounded border border-red-700">
          <p className="font-semibold">Error</p>
          <p className="text-sm">{error}</p>
        </div>
      )}

      {success && (
        <div className="bg-green-600 text-white p-3 rounded border border-green-700">
          <p className="font-semibold">Success!</p>
          <p className="text-sm">{success}</p>
          {txHash && (
            <a 
              href={`https://sepolia.arbiscan.io/tx/${txHash}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-200 hover:underline text-sm mt-2 block"
            >
              View on Arbiscan
            </a>
          )}
        </div>
      )}

      <button
        type="submit"
        disabled={loading || !isConnected}
        className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 p-3 rounded font-bold transition"
      >
        {loading ? `${action.charAt(0).toUpperCase() + action.slice(1)}ing...` : action.charAt(0).toUpperCase() + action.slice(1)}
      </button>
    </form>
  );
}
