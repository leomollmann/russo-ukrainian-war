import torch
from torch import nn
import torch.nn.functional as F
from torch.utils.data import TensorDataset

device = 'cuda' if torch.cuda.is_available() else 'cpu'

class NeuralNet(nn.Module):
  def __init__(self):
    super(NeuralNet, self).__init__()

    self.f_connected1 = nn.Linear(8, 64)
    self.out = nn.Linear(64, 2)
  
  def forward(self, x):
    x = F.relu(self.f_connected1(x))
    x = self.out(x)
    return x

  def iter_train(self, dataloader, loss_fn, optimizer):
    self.train()
    train_loss = 0

    for i, (X, y) in enumerate(dataloader):
      X, y = X.to(device), y.to(device)

      y_hat = self.forward(X)
      ce = loss_fn(y_hat, y)
      train_loss += ce.item()

      optimizer.zero_grad()
      ce.backward()
      optimizer.step()
    
    num_batches = len(dataloader)
    return train_loss / num_batches

  def iter_validate(self, dataloader, loss_fn):
    self.eval()
    test_loss = 0

    with torch.no_grad():
      for X, y in dataloader:
        X, y = X.to(device), y.to(device)
        y_hat = self(X)
        test_loss += loss_fn(y_hat, y).item()
    
    num_batches = len(dataloader)
    return test_loss / num_batches

  def predict(self, ds: TensorDataset): 
    self.eval()
    output = []
    for tensor in ds.tensors:
      output.append(self(tensor))

    return output

  def save(self, model_path):
    torch.save(self.state_dict(), model_path)

  def load(self, model_path):
    self.load_state_dict(torch.load(model_path))
    self.eval()
