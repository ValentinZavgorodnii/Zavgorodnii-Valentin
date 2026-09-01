import numpy as np
import pandas as pd


def generator_fintech_data(n_users = 100000, effect_size = 15, correlation = 0.8, random_state = 42):

    rng = np.random.RandomState(random_state)

    mu, sigma = 6.0, 1.2
    
    pre_exp_revenue = rng.lognormal(mean=mu, sigma=sigma, size=n_users)
    
    groups = rng.choice(['Control', 'Treatment'], size=n_users, p=[0.5, 0.5])
    
    noise_variance = np.var(pre_exp_revenue) * (1 - correlation ** 2)
    
    noise = rng.normal(loc=0, scale=np.sqrt(noise_variance), size=n_users)
    
    exp_revenue = correlation * pre_exp_revenue + noise
    
    exp_revenue = np.maximum(0, exp_revenue)
    
    treatment_mask = (groups == 'Treatment')
    exp_revenue[treatment_mask] += effect_size
    
    df = pd.DataFrame({
        'user_id': range(1, n_users + 1),
        'group': groups,
        'pre_exp_revenue': np.round(pre_exp_revenue, 2),
        'exp_revenue': np.round(exp_revenue, 2)
    })
    
    return df
