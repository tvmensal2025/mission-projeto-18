-- Inserir chave do Google AI para Sofia e Dr. Vital
INSERT INTO vault.secrets (name, secret) 
VALUES ('GOOGLE_AI_API_KEY', 'AIzaSyBWZoG3PL-H4cF6QNXY9Y8qJOKKWGkNr0w')
ON CONFLICT (name) DO UPDATE SET secret = EXCLUDED.secret;